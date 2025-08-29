import 'dart:math';

import 'package:collection/collection.dart';
import 'package:digit_data_model/data/data_repository.dart';
import 'package:digit_ui_components/theme/spacers.dart';
import 'package:digit_ui_components/widgets/molecules/digit_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:registration_delivery/data/repositories/local/project_beneficiary.dart';
import 'package:registration_delivery/models/entities/project_beneficiary.dart';
import 'package:registration_delivery/utils/utils.dart';
import 'package:registration_delivery/widgets/progress_indicator/progress_indicator.dart';

import 'package:digit_ui_components/theme/digit_extended_theme.dart';
import 'package:digit_ui_components/theme/spacers.dart';
import 'package:flutter/material.dart';

class CustomBeneficiaryProgressBar extends StatefulWidget {
  final String label;
  final String prefixLabel;

  const CustomBeneficiaryProgressBar({
    super.key,
    required this.label,
    required this.prefixLabel,
  });

  @override
  State<CustomBeneficiaryProgressBar> createState() =>
      CustomBeneficiaryProgressBarState();
}

class CustomBeneficiaryProgressBarState
    extends State<CustomBeneficiaryProgressBar> {
  int current = 0;

  @override
  void didChangeDependencies() {
    final repository = context.read<
            LocalRepository<ProjectBeneficiaryModel,
                ProjectBeneficiarySearchModel>>()
        as ProjectBeneficiaryLocalRepository;

    final now = DateTime.now();
    final gte = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final lte = DateTime(
      now.year,
      now.month,
      now.day,
      23,
      59,
      59,
      999,
    );

    repository.listenToChanges(
      query: ProjectBeneficiarySearchModel(
        projectId: [RegistrationDeliverySingleton().projectId.toString()],
      ),
      listener: (data) {
        if (mounted) {
          setState(() {
            current = data
                .where((element) =>
                    element.dateOfRegistrationTime.isAfter(gte) &&
                    (element.isDeleted == false || element.isDeleted == null) &&
                    element.dateOfRegistrationTime.isBefore(lte))
                .length;
          });
        }
      },
    );
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final selectedProject = RegistrationDeliverySingleton().selectedProject!;
    final beneficiaryType = RegistrationDeliverySingleton().beneficiaryType;

    final targetModel = selectedProject.targets?.firstWhereOrNull(
      (element) => element.beneficiaryType == beneficiaryType,
    );

    // final target = targetModel?.targetNo ?? 0.0;

    const int target = 70;

    return DigitCard(margin: const EdgeInsets.all(spacer2), children: [
      CustomProgressIndicatorContainer(
        label: '${max(target - current, 0).round()} ${widget.label}',
        prefixLabel: '$current ${widget.prefixLabel}',
        suffixLabel: target.toStringAsFixed(0),
        value: target == 0 ? 0 : min(current / target, 1),
      ),
    ]);
  }
}


class CustomProgressIndicatorContainer extends StatelessWidget {
  final String label;
  final String prefixLabel;
  final String suffixLabel;
  final double value;
  final String? subLabel;
  final Animation<Color?>? valueColor;

  const CustomProgressIndicatorContainer({
    super.key,
    required this.label,
    required this.prefixLabel,
    required this.suffixLabel,
    required this.value,
    this.valueColor,
    this.subLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.digitTextTheme(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Text(
          label,
          style: textTheme.bodyS,
          textAlign: TextAlign.center,
        ),
        Padding(
          padding: const EdgeInsets.all(spacer2 * 2),
          child: Column(
            children: [
              LinearProgressIndicator(
                backgroundColor: theme.colorTheme.generic.background,
                valueColor: valueColor ??
                    AlwaysStoppedAnimation<Color>(
                      theme.colorTheme.alert.success,
                    ),
                value: value,
                minHeight: 7.0,
              ),
              Padding(
                padding: const EdgeInsets.only(top: spacer2 + 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      prefixLabel,
                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorTheme.alert.success),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      suffixLabel,
                      style: textTheme.bodyS,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (subLabel != null)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(spacer2),
              child: Text(
                subLabel ?? '',
                style: TextStyle(
                  color: theme.colorTheme.text.secondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}

