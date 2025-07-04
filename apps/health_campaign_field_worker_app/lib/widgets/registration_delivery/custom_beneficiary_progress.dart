import 'dart:math';

import 'package:collection/collection.dart';
import 'package:digit_components/widgets/digit_card.dart';
import 'package:digit_data_model/data/data_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:registration_delivery/data/repositories/local/task.dart';
import 'package:registration_delivery/models/entities/status.dart';
import 'package:registration_delivery/models/entities/task.dart';
import 'package:registration_delivery/registration_delivery.dart';

import '../../data/repositories/custom_task.dart';
// import '../../progress_indicator/progress_indicator.dart';
import '../progress_indicator/progress_indicator.dart';

import 'package:digit_ui_components/digit_components.dart';
import 'package:digit_ui_components/theme/digit_extended_theme.dart';
import 'package:flutter/material.dart';

class CustomBeneficiaryProgressBar extends StatefulWidget {
  final String label;
  final String prefixLabel;

  const CustomBeneficiaryProgressBar({
    Key? key,
    required this.label,
    required this.prefixLabel,
  }) : super(key: key);

  @override
  State<CustomBeneficiaryProgressBar> createState() =>
      _CustomBeneficiaryProgressBarState();
}

class _CustomBeneficiaryProgressBarState
    extends State<CustomBeneficiaryProgressBar> {
  int current = 0;
  @override
  void didChangeDependencies() {
    final taskRepository =
        context.read<LocalRepository<TaskModel, TaskSearchModel>>()
            as CustomTaskLocalRepository;

    final projectId = RegistrationDeliverySingleton().projectId;
    final loggedInUserUuid = RegistrationDeliverySingleton().loggedInUserUuid;

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

    taskRepository.listenToChanges(
      query: TaskSearchModel(
        status: Status.administeredSuccess.toValue(),
        projectId: projectId,
        createdBy: loggedInUserUuid,
        plannedEndDate: lte.millisecondsSinceEpoch,
        plannedStartDate: gte.millisecondsSinceEpoch,
      ),
      listener: (taskData) async {
        if (mounted) {
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
          TaskSearchModel taskSearchQuery = TaskSearchModel(
            status: Status.administeredSuccess.toValue(),
            createdBy: loggedInUserUuid,
            plannedEndDate: lte.millisecondsSinceEpoch,
            plannedStartDate: gte.millisecondsSinceEpoch,
            projectId: projectId,
          );
          List<TaskModel> results =
              await taskRepository.progressBarSearch(taskSearchQuery);
          final groupedEntries = results.groupListsBy(
            (element) => element.projectBeneficiaryClientReferenceId,
          );
          if (mounted) {
            setState(() {
              if (mounted) {
                current = groupedEntries.entries.length;
              }
            });
          }
        }
      },
    );
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    const target = 70;

    return DigitCard(
      child: CustomProgressIndicatorContainer(
        label: '${max(target - current, 0).round()} ${widget.label}',
        prefixLabel: '$current ${widget.prefixLabel}',
        suffixLabel: target.toStringAsFixed(0),
        value: target == 0 ? 0 : min(current / target, 1),
      ),
    );
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

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Text(
          label,
          style: theme.textTheme.bodyMedium,
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
                      theme.colorTheme.primary.primary1,
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
                      style: theme.textTheme.bodyMedium!.copyWith(color: theme.colorTheme.alert.success),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      suffixLabel,
                      style: theme.textTheme.bodyMedium,
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
                  color: theme.colorTheme.primary.primary1,
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
