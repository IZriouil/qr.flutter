/*
 * QR.Flutter
 * Copyright (c) 2019 the QR.Flutter authors.
 * See LICENSE for distribution and usage details.
 */

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

const double _defaultGapBlendImageSize = 2.0;

/// A widget that shows a QR code.
class QrImageBlendView extends StatefulWidget {
  /// Create a new QR code using the [String] data and the passed options (or
  /// using the default options).
  QrImageBlendView({
    required String data,
    super.key,
    this.size,
    this.padding = const EdgeInsets.all(10.0),
    this.backgroundColor = Colors.transparent,
    this.backgroundImage,
    this.version = QrVersions.auto,
    this.errorCorrectionLevel = QrErrorCorrectLevel.L,
    this.errorStateBuilder,
    this.constrainErrorBounds = true,
    this.gapSize = 2.0,
    this.semanticsLabel = 'qr code',
    this.eyeStyle = const QrEyeStyle(
      eyeShape: QrEyeShape.square,
      color: Colors.black,
    ),
    this.emptyColor = Colors.white,
    this.dataModuleStyle = const QrDataModuleStyle(
      dataModuleShape: QrDataModuleShape.square,
      color: Colors.black,
    ),
    @Deprecated('use colors in eyeStyle and dataModuleStyle instead') this.foregroundColor,
  })  : assert(
          QrVersions.isSupportedVersion(version),
          'QR code version $version is not supported',
        ),
        _data = data,
        _qrCode = null;

  /// Create a new QR code using the [QrCode] data and the passed options (or
  /// using the default options).
  QrImageBlendView.withQr({
    required QrCode qr,
    super.key,
    this.size,
    this.padding = const EdgeInsets.all(10.0),
    this.backgroundColor = Colors.transparent,
    this.version = QrVersions.auto,
    this.errorCorrectionLevel = QrErrorCorrectLevel.L,
    this.errorStateBuilder,
    this.constrainErrorBounds = true,
    this.backgroundImage,
    this.gapSize = 2.0,
    this.emptyColor = Colors.white,
    this.semanticsLabel = 'qr code',
    this.eyeStyle = const QrEyeStyle(
      eyeShape: QrEyeShape.square,
      color: Colors.black,
    ),
    this.dataModuleStyle = const QrDataModuleStyle(
      dataModuleShape: QrDataModuleShape.square,
      color: Colors.black,
    ),
    @Deprecated('use colors in eyeStyle and dataModuleStyle instead') this.foregroundColor,
  })  : assert(
          QrVersions.isSupportedVersion(version),
          'QR code version $version is not supported',
        ),
        _data = null,
        _qrCode = qr;

  // The data passed to the widget
  final String? _data;

  // The QR code data passed to the widget
  final QrCode? _qrCode;

  /// The background color of the final QR code widget.
  final Color backgroundColor;

  final ImageProvider? backgroundImage;

  // in image blend mode, empty color is used to fill the empty dots
  final Color emptyColor;

  /// The QR code version to use.
  final int version;

  /// The QR code error correction level to use.
  final int errorCorrectionLevel;

  /// The external padding between the edge of the widget and the content.
  final EdgeInsets padding;

  /// The intended size of the widget.
  final double? size;

  /// The callback that is executed in the event of an error so that you can
  /// interrogate the exception and construct an alternative view to present
  /// to your user.
  final QrErrorBuilder? errorStateBuilder;

  /// If `true` then the error widget will be constrained to the boundary of the
  /// QR widget if it had been valid. If `false` the error widget will grow to
  /// the size it needs. If the error widget is allowed to grow, your layout may
  /// jump around (depending on specifics).
  ///
  /// NOTE: Setting a [size] value will override this setting and both the
  /// content widget and error widget will adhere to the size value.
  final bool constrainErrorBounds;

  /// Gap between the points.
  final double gapSize;

  /// [semanticsLabel] will be used by screen readers to describe the content of
  /// the qr code.
  /// Default is 'qr code'.
  final String semanticsLabel;

  /// Styling option for QR Eye ball and frame.
  final QrEyeStyle eyeStyle;

  /// Styling option for QR data module.
  final QrDataModuleStyle dataModuleStyle;

  /// The foreground color of the final QR code widget.
  @Deprecated('use colors in eyeStyle and dataModuleStyle instead')
  final Color? foregroundColor;

  @override
  State<QrImageBlendView> createState() => _QrImageBlendViewState();
}

class _QrImageBlendViewState extends State<QrImageBlendView> {
  /// The QR code string data.
  QrCode? _qr;

  /// The current validation status.
  late QrValidationResult _validationResult;

  @override
  Widget build(BuildContext context) {
    if (widget._data != null) {
      _validationResult = QrValidator.validate(
        data: widget._data!,
        version: widget.version,
        errorCorrectionLevel: widget.errorCorrectionLevel,
      );
      _qr = _validationResult.isValid ? _validationResult.qrCode : null;
    } else if (widget._qrCode != null) {
      _qr = widget._qrCode;
      _validationResult = QrValidationResult(status: QrValidationStatus.valid, qrCode: _qr);
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        // validation failed, show an error state widget if builder is present.
        if (!_validationResult.isValid) {
          return _errorWidget(context, constraints, _validationResult.error);
        }
        // no error, build the regular widget
        final widgetSize = widget.size ?? constraints.biggest.shortestSide;
        return _qrWidget(widgetSize);
      },
    );
  }

  Widget _qrWidget(double edgeLength) {
    final painter = QrPainter.withQr(
      qr: _qr!,
      // ignore: deprecated_member_use_from_same_package
      color: widget.foregroundColor,
      gapless: false,
      gapSize: widget.gapSize,
      eyeStyle: widget.eyeStyle,
      dataModuleStyle: widget.dataModuleStyle,
      emptyColor: widget.emptyColor.withOpacity(.8),
    );
    return _QrContentView(
      edgeLength: edgeLength,
      backgroundColor: widget.backgroundColor,
      padding: widget.padding,
      backgroundImage: widget.backgroundImage,
      semanticsLabel: widget.semanticsLabel,
      child: CustomPaint(painter: painter),
    );
  }

  Widget _errorWidget(
    BuildContext context,
    BoxConstraints constraints,
    Object? error,
  ) {
    final errorWidget =
        widget.errorStateBuilder == null ? Container() : widget.errorStateBuilder!(context, error);
    final errorSideLength = widget.constrainErrorBounds
        ? widget.size ?? constraints.biggest.shortestSide
        : constraints.biggest.longestSide;
    return _QrContentView(
      edgeLength: errorSideLength,
      backgroundColor: widget.backgroundColor,
      backgroundImage: widget.backgroundImage,
      padding: widget.padding,
      semanticsLabel: widget.semanticsLabel,
      child: errorWidget,
    );
  }
}

class _QrContentView extends StatelessWidget {
  const _QrContentView({
    required this.edgeLength,
    required this.child,
    this.backgroundColor,
    this.backgroundImage,
    this.padding,
    this.semanticsLabel,
  });

  /// The length of both edges (because it has to be a square).
  final double edgeLength;

  /// The background color of the containing widget.
  final Color? backgroundColor;

  /// The background color of the containing widget.
  final ImageProvider? backgroundImage;

  /// The padding that surrounds the child widget.
  final EdgeInsets? padding;

  /// The child widget.
  final Widget child;

  /// [semanticsLabel] will be used by screen readers to describe the content of
  /// the qr code.
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticsLabel,
      child: Container(
        width: edgeLength,
        height: edgeLength,
        decoration: BoxDecoration(
          color: backgroundColor,
          image: backgroundImage != null
              ? DecorationImage(
                  image: backgroundImage!,
                  // fit: BoxFit.contain,
                  fit: BoxFit.cover,
                )
              : null,
        ),
        // color: backgroundColor,
        child: Padding(
          padding: padding!,
          child: child,
        ),
      ),
    );
  }
}
