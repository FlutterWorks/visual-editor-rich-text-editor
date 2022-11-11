import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:visual_editor/visual-editor.dart';

import '../const/dimensions.const.dart';
import '../models/markers-and-scroll-offset.model.dart';
import '../widgets/demo-scaffold.dart';
import '../widgets/loading.dart';
import '../widgets/markers-attachments.dart';
import 'delete-markers.page.dart';

// Markers rectangles can be hidden by type from the document.
// Markers are not deleted so we still can use their information
// i.e. even though the markers are hidden, markers attachments still works properly
class HideMarkersPage extends StatefulWidget {
  @override
  _HideMarkersPageState createState() => _HideMarkersPageState();
}

class _HideMarkersPageState extends State<HideMarkersPage> {
  EditorController? _controller;
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();

  // (!) This stream is extremely important for maintaining the page performance when updating the attachments positions.
  // The _updateMarkerAttachments() method will be called many times per second when scrolling.
  // Therefore we want to avoid at all costs to setState() in the parent MarkersAttachmentsPage.
  // We will update only the MarkersAttachmentsSidebar via the stream.
  // By using this trick we can prevent Flutter from running expensive page updates.
  // We will target our updates only on the area that renders the attachments (far better performance).
  final _markers$ = StreamController<MarkersAndScrollOffset>.broadcast();

  @override
  void initState() {
    _loadDocument();
    super.initState();
  }

  @override
  Widget build(BuildContext context) => _scaffold(
        children: _controller != null
            ? [
                _flexibleRow(
                  children: [
                    _markersAttachments(),
                    _editor(),
                    _fillerToBalanceRow(),
                  ],
                ),
                _markersControls(),
                _toolbar(),
              ]
            : [
                Loading(),
              ],
      );

  Widget _scaffold({required List<Widget> children}) => DemoScaffold(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: children,
        ),
      );

  Widget _editor() => Flexible(
        child: Container(
          width: PAGE_WIDTH,
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: VisualEditor(
            controller: _controller!,
            scrollController: _scrollController,
            focusNode: _focusNode,
            config: EditorConfigM(),
          ),
        ),
      );

  Widget _flexibleRow({required List<Widget> children}) => Flexible(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      );

  Widget _markersAttachments() => MarkersAttachments(
        markers$: _markers$,
      );

  // Row is space in between, therefore we need on the right side an empty container to force the editor on the center.
  Widget _fillerToBalanceRow() => Container(width: 0);

  Widget _markersControls() => Container(
    margin: EdgeInsets.only(top: 15),
    child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton(
              child: Text('Toggle Reminder Markers'),
              onPressed: () {
                final visibility =
                    !(_controller?.getMarkersVisibilityByTypes(['reminder']) ??
                        false);

                _controller?.toggleMarkersByTypes(['reminder'], visibility);
              },
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 25),
              child: OutlinedButton(
                child: Text('Toggle Expert Markers'),
                onPressed: () {
                  final visibility =
                      !(_controller?.getMarkersVisibilityByTypes(['expert']) ??
                          false);

                  _controller?.toggleMarkersByTypes(['expert'], visibility);
                },
              ),
            ),
            OutlinedButton(
              child: Text('Toggle Expert And Beginner Markers'),
              onPressed: () {
                final visibility = !(_controller?.getMarkersVisibilityByTypes(
                      ['expert', 'beginner'],
                    ) ??
                    false);

                _controller?.toggleMarkersByTypes(
                  ['expert', 'beginner'],
                  visibility,
                );
              },
            ),
          ],
        ),
  );

  Widget _toolbar() => Container(
        padding: EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 8,
        ),
        child: EditorToolbar.basic(
          controller: _controller!,
          showMarkers: true,
          multiRowsDisplay: false,
        ),
      );

  Future<void> _loadDocument() async {
    final deltaJson =
        await rootBundle.loadString('assets/docs/hide-markers.json');
    final document = DocumentM.fromJson(jsonDecode(deltaJson));

    setState(() {
      _initEditorController(document);
    });
  }

  void _initEditorController(DocumentM document) {
    _controller = EditorController(
      document: document,
      markerTypes: [
        MarkerTypeM(
          id: 'expert',
          name: 'Expert',
          color: Colors.amber.withOpacity(0.2),
          onAddMarkerViaToolbar: (_) => 'fake-id-1',
          onSingleTapUp: (marker) {
            print('Marker Tapped - ${marker.type}');
          },
        ),
        MarkerTypeM(
          id: 'beginner',
          name: 'Beginner',
          color: Colors.blue.withOpacity(0.2),
          onAddMarkerViaToolbar: (_) => 'fake-id-2',
          onSingleTapUp: (marker) {
            print('Marker Tapped - ${marker.type}');
          },
        ),
        MarkerTypeM(
          id: 'reminder',
          name: 'Reminder',
          color: Colors.cyan.withOpacity(0.2),
          onAddMarkerViaToolbar: (_) => 'fake-id-3',
          onSingleTapUp: (marker) {
            print('Marker Tapped - ${marker.type}');
          },
        ),
      ],
      onBuildComplete: _updateMarkerAttachments,
      onScroll: _updateMarkerAttachments,
    );
  }

  // From here on it's up to the client developer to decide how to draw the attachments.
  // Once you have the build and scroll updates + the pixel coordinates, you can do whatever you want.
  // (!) Inspect the coordinates to draw only the markers that are still visible in the viewport.
  // (!) This method will be invoked many times by the scroll callback.
  // (!) Avoid heavy computations here, otherwise your page might slow down.
  // (!) Avoid setState() on the parent page, setState in a smallest possible widget to minimise the update cost.
  void _updateMarkerAttachments() {
    final markers = _controller?.getAllMarkers() ?? [];
    _markers$.sink.add(
      MarkersAndScrollOffset(
        markers: markers,
        scrollOffset: SCROLLABLE ? _scrollController.offset : 0,
      ),
    );
  }
}
