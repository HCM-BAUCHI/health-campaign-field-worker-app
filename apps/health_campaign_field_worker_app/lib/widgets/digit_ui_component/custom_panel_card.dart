import 'package:digit_ui_components/digit_components.dart';
import 'package:digit_ui_components/theme/ComponentTheme/panel_theme.dart';
import 'package:digit_ui_components/theme/digit_extended_theme.dart';
import 'package:digit_ui_components/widgets/atoms/panel.dart';
import 'package:digit_ui_components/widgets/helper_widget/button_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:lottie/lottie.dart';

class CustomPanelCard extends StatefulWidget {
  final PanelType type;
  final String title;
  final Map<String, String>? subTitle;
  final List<Text>? additionalDetails;
  final String? description;
  final List<Widget>? additionWidgets;
  final List<DigitButton>? actions;
  final double? actionSpacing;
  final bool? inlineActions;
  final MainAxisAlignment? actionAlignment;
  final bool? animate;
  final bool? repeat;

  const CustomPanelCard({
    super.key,
    required this.title,
    this.subTitle,
    required this.type,
    this.additionalDetails,
    this.description,
    this.additionWidgets,
    this.actions,
    this.inlineActions,
    this.actionSpacing,
    this.actionAlignment,
    this.animate,
    this.repeat,
  });

  @override
  _CustomPanelCardState createState() => _CustomPanelCardState();
}

class _CustomPanelCardState extends State<CustomPanelCard> {
  final _scrollController = ScrollController();
  bool _isOverflowing = false;
  bool firstBuild = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildContent(
      DigitTypography currentTypography, bool isMobile, bool isTab) {
    Widget list = Padding(
      padding: EdgeInsets.only(
        left: isMobile
            ? spacer4
            : isTab
                ? spacer5
                : spacer6,
        right: isMobile
            ? spacer4
            : isTab
                ? spacer5
                : spacer6,
        top: _isOverflowing
            ? (isMobile
                ? spacer4
                : isTab
                    ? spacer5
                    : spacer6)
            : 0,
        bottom: !_isOverflowing && (widget.actions != null)
            ? 0
            : isMobile
                ? spacer4
                : isTab
                    ? spacer5
                    : spacer6,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.description != null)
            Text(
              widget.description!,
              style: currentTypography.bodyS.copyWith(
                color: const DigitColors().light.textPrimary,
              ),
            ),
          if (widget.description != null && widget.additionWidgets != null)
            SizedBox(
              height: isMobile
                  ? spacer4
                  : isTab
                      ? spacer5
                      : spacer6,
            ),
          if (widget.additionWidgets != null)
            ...widget.additionWidgets!
                .asMap()
                .entries
                .map(
                  (widgets) => Padding(
                    padding: EdgeInsets.only(
                      bottom: widgets.key != widget.additionWidgets!.length - 1
                          ? (isMobile
                              ? spacer4
                              : isTab
                                  ? spacer5
                                  : spacer6)
                          : 0,
                    ),
                    child: widgets.value,
                  ),
                )
                .toList(),
        ],
      ),
    );

    return Flexible(
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [list],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!firstBuild) {
      firstBuild = true;
      SchedulerBinding.instance.addPostFrameCallback((_) {
        setState(() {
          if (_scrollController.hasClients) {
            _isOverflowing = (_scrollController.position.maxScrollExtent > 0);
          }
        });
      });
    }
    DigitTypography currentTypography = getTypography(context, false);
    bool isMobile = AppView.isMobileView(MediaQuery.of(context).size);
    bool isTab = AppView.isTabletView(MediaQuery.of(context).size);

    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(spacer1),
        color: const DigitColors().light.paperPrimary,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withOpacity(.16),
            offset: const Offset(0, 1),
            spreadRadius: 0,
            blurRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: isMobile
                ? const EdgeInsets.all(spacer4)
                : EdgeInsets.all(
                    isTab ? spacer5 : spacer6,
                  ),
            decoration: BoxDecoration(
              color: const DigitColors().light.paperPrimary,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(spacer1),
                  topRight: Radius.circular(spacer1)),
              boxShadow: _isOverflowing
                  ? [
                      BoxShadow(
                        color: const Color(0xFF000000).withOpacity(.16),
                        offset: const Offset(0, 1),
                        spreadRadius: 0,
                        blurRadius: 2,
                      ),
                    ]
                  : [],
            ),
            child: Panel(
              type: widget.type,
              title: widget.title,
              subTitle: widget.subTitle,
              description: widget.additionalDetails,
              animate: widget.animate ?? true,
              repeat: widget.repeat ?? false,
            ),
          ),
          if (widget.description != null || widget.additionWidgets != null)
            _buildContent(currentTypography, isMobile, isTab),
          if (widget.actions != null)
            Container(
                padding: EdgeInsets.only(
                  left: isMobile
                      ? spacer4
                      : isTab
                          ? spacer5
                          : spacer6,
                  right: isMobile
                      ? spacer4
                      : isTab
                          ? spacer5
                          : spacer6,
                  top: _isOverflowing ||
                          (widget.additionWidgets != null ||
                              widget.description != null)
                      ? isMobile
                          ? spacer4
                          : isTab
                              ? spacer5
                              : spacer6
                      : 0,
                  bottom: isMobile
                      ? spacer4
                      : isTab
                          ? spacer5
                          : spacer6,
                ),
                decoration: BoxDecoration(
                  color: const DigitColors().light.paperPrimary,
                  borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(spacer1),
                      bottomRight: Radius.circular(spacer1)),
                  boxShadow: _isOverflowing
                      ? [
                          BoxShadow(
                            color: const Color(0xFF000000).withOpacity(.16),
                            offset: const Offset(0, -1),
                            spreadRadius: 0,
                            blurRadius: 2,
                          ),
                        ]
                      : [],
                ),
                child: DigitButtonListTile(
                  buttons: widget.actions!,
                  isVertical: widget.inlineActions != null
                      ? !widget.inlineActions!
                      : (isMobile ? true : false),
                  alignment: widget.actionAlignment ??
                      ((isMobile || isTab)
                          ? MainAxisAlignment.center
                          : MainAxisAlignment.end),
                  spacing: widget.actionSpacing ??
                      (isMobile
                          ? spacer4
                          : isTab
                              ? spacer5
                              : spacer6),
                )),
        ],
      ),
    );
  }
}

class Panel extends StatefulWidget {
  final PanelType type;
  final String title;
  final Map<String, String>? subTitle;
  final List<Text>? description;
  final bool animate;
  final bool repeat;
  final PanelThemeData? panelThemeData;

  const Panel({
    Key? key,
    required this.type,
    required this.title,
    required this.subTitle,
    this.description,
    this.animate = true,
    this.repeat = false,
    this.panelThemeData,
  }) : super(key: key);

  @override
  _PanelState createState() => _PanelState();
}

class _PanelState extends State<Panel> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final themeData = widget.panelThemeData ??
        theme.extension<PanelThemeData>() ??
        PanelThemeData.defaultTheme(context);

    bool isMobile = AppView.isMobileView(MediaQuery.of(context).size);
    bool isTab = AppView.isTabletView(MediaQuery.of(context).size);

    return Container(
      padding: widget.type == PanelType.success
          ? themeData.successPadding
          : themeData.errorPadding,
      width: themeData.cardWidth,
      decoration: BoxDecoration(
        color: widget.type == PanelType.success
            ? themeData.successBackgroundColor
            : themeData.errorBackgroundColor,
        borderRadius: themeData.radiusGeometry,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            widget.title,
            textAlign: TextAlign.center,
            style: themeData.titleTextStyle,
          ),
          Lottie.asset(
            widget.type == PanelType.success
                ? themeData.successJson
                : themeData.errorJson,
            controller: _controller,
            onLoaded: (composition) {
              _controller.duration = composition.duration;
              if (widget.animate == true) {
                if (widget.repeat == true) {
                  _controller.repeat();
                } else {
                  _controller.forward();
                }
              } else {
                _controller.value = 1.0;

                /// Move to the last frame
              }
            },
            width: widget.type == PanelType.success
                ? themeData.successAnimationSize
                : themeData.errorAnimationSize,
            height: widget.type == PanelType.success
                ? themeData.successAnimationSize
                : themeData.errorAnimationSize,
            fit: BoxFit.fill,
          ),
          SizedBox(
            height: widget.type == PanelType.success
                ? 0
                : isMobile
                    ? theme.spacerTheme.spacer4
                    : isTab
                        ? theme.spacerTheme.spacer5
                        : theme.spacerTheme.spacer6,
          ),
          Text(
            widget.subTitle?['id'] ?? "",
            textAlign: TextAlign.center,
            style: themeData.titleTextStyle.copyWith(fontSize: 16),
          ),
          Text(
            widget.subTitle?['value'] ?? "",
            textAlign: TextAlign.center,
            style: themeData.titleTextStyle,
          ),
          if (widget.description != null)
            SizedBox(
              height: theme.spacerTheme.spacer6,
            ),
          if (widget.description != null)
            ...widget.description!
                .asMap()
                .entries
                .map((widgets) => Padding(
                      padding: EdgeInsets.only(
                          bottom: widgets.key != widget.description!.length - 1
                              ? theme.spacerTheme.spacer1
                              : 0),
                      child: widgets.value,
                    ))
                .toList(),
        ],
      ),
    );
  }
}
