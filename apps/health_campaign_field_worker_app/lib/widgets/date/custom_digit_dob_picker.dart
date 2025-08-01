import 'package:digit_components/digit_components.dart';
import '../../../utils/date_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reactive_forms/reactive_forms.dart';

class CustomDigitDobPicker extends StatelessWidget {
  // Properties to hold the form control name, labels, and error messages for the components
  final String datePickerFormControl;
  final bool isVerified;
  final ControlValueAccessor? valueAccessor;
  final String datePickerLabel;
  final String ageFieldLabel;
  final String yearsHintLabel;
  final String monthsHintLabel;
  final String separatorLabel;
  final String yearsAndMonthsErrMsg;
  final String cancelText;
  final String confirmText;
  final DateTime? initialDate;
  final DateTime? finalDate;
  final void Function(FormControl<dynamic>)? onChangeOfFormControl;

  const CustomDigitDobPicker({
    super.key,
    required this.datePickerFormControl,
    this.isVerified = false,
    this.valueAccessor,
    required this.datePickerLabel,
    required this.ageFieldLabel,
    required this.yearsHintLabel,
    required this.monthsHintLabel,
    required this.separatorLabel,
    required this.yearsAndMonthsErrMsg,
    this.initialDate,
    this.finalDate,
    this.confirmText = 'OK',
    this.cancelText = 'Cancel',
    this.onChangeOfFormControl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(
        top: 8,
        bottom: 8,
      ),
      child: Container(
        padding: const EdgeInsets.only(
          left: 8,
          right: 8,
          bottom: 8,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
              color: Colors.grey, style: BorderStyle.solid, width: 1.0),
        ),
        child: Column(
          children: [
            // Date picker component to select the date of birth
            DigitDateFormPicker(
              label: datePickerLabel,
              isRequired: true,
              start: initialDate,
              formControlName: datePickerFormControl,
              cancelText: cancelText,
              confirmText: confirmText,
              onChangeOfFormControl: onChangeOfFormControl,
              end: finalDate ?? DateTime.now(),
            ),
            const SizedBox(height: 16),
            // Text widget to display a separator label between the date picker and age fields
            Text(
              separatorLabel,
              style: theme.textTheme.bodyLarge,
            ),
            Row(
              children: [
                Expanded(
                  // Text form field for entering the age in years
                  child: DigitTextFormField(
                      padding: EdgeInsets.zero,
                      maxLength: 3,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      valueAccessor:
                          DobValueAccessorYearsString(DobValueAccessor()),
                      formControlName: datePickerFormControl,
                      label: ageFieldLabel,
                      isRequired: true,
                      keyboardType: TextInputType.number,
                      suffix: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          yearsHintLabel,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      readOnly: isVerified,
                      onChanged: onChangeOfFormControl),
                ),
                const SizedBox(
                  width: 8,
                ),
                Expanded(
                  // Text form field for entering the age in months
                  child: DigitTextFormField(
                      padding: EdgeInsets.zero,
                      maxLength: 2,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        MonthsValueValidator(),
                      ],
                      valueAccessor:
                          DobValueAccessorMonthString(DobValueAccessor()),
                      formControlName: datePickerFormControl,
                      label: '',
                      keyboardType: TextInputType.number,
                      suffix: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          monthsHintLabel,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      readOnly: isVerified,
                      onChanged: onChangeOfFormControl),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            ReactiveFormConsumer(
              builder: (context, form, child) {
                final datePickerControl = form.control(datePickerFormControl);
                if (datePickerControl.hasError('monthsRange')) {
                  return Text(
                    'Month value must be between 0 and 11',
                    style:
                        TextStyle(color: DigitTheme.instance.colorScheme.error),
                  );
                } else if (datePickerControl.hasErrors) {
                  return Text(
                    yearsAndMonthsErrMsg,
                    style:
                        TextStyle(color: DigitTheme.instance.colorScheme.error),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

// A custom ControlValueAccessor to convert the model value (DateTime) to the view value (DigitDOBAge) and vice versa.
class DobValueAccessor extends ControlValueAccessor<DateTime, DigitDOBAge> {
  @override
  DigitDOBAge? modelToViewValue(DateTime? modelValue) {
    if (modelValue == null) {
      return null;
    } else {
      return DigitDateUtils.calculateAge(modelValue);
    }
  }

  @override
  DateTime? viewToModelValue(DigitDOBAge? viewValue) {
    if (viewValue == null || (viewValue.years == 0 && viewValue.months == 0)) {
      return null;
    } else if (viewValue.months > 11) {
      // Invalid months value - handle validation error at the form level
      return null;
    } else {
      return DigitDateUtils.calculateDob(viewValue);
    }
  }
}

// A custom ControlValueAccessor to handle the view value as a string for years.
class DobValueAccessorYearsString
    extends ControlValueAccessor<DateTime, String> {
  final DobValueAccessor accessor;

  DobValueAccessorYearsString(this.accessor);
  String existingMonth = '';
  String existingDays = '';

  @override
  String? modelToViewValue(DateTime? modelValue) {
    final dobAge = accessor.modelToViewValue(modelValue);
    if (dobAge == null || (dobAge.years == 0 && dobAge.months == 0)) {
      existingMonth = '';
      existingDays = '';
      return null;
    }

    existingMonth = dobAge.months.toString();
    existingDays = dobAge.days.toString();
    return dobAge.years.toString();
  }

  @override
  DateTime? viewToModelValue(String? viewValue) {
    final years = int.tryParse(viewValue ?? '');

    final dobAge = DigitDOBAge(
        years: years ?? 0,
        months: int.tryParse(existingMonth) ?? 0,
        days: int.tryParse(existingDays) ?? 0);
    return accessor.viewToModelValue(dobAge);
  }
}

// This class validates that months input is between 0-11
class MonthsValueValidator extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }
    
    int? value = int.tryParse(newValue.text);
    if (value != null && value >= 0 && value <= 11) {
      return newValue;
    }
    
    // Return the old value if the new value is invalid
    return oldValue;
  }
}

// A custom ControlValueAccessor to handle the view value as a string for months.
class DobValueAccessorMonthString
    extends ControlValueAccessor<DateTime, String> {
  final DobValueAccessor accessor;

  DobValueAccessorMonthString(this.accessor);
  String existingYear = '';
  String existingDays = '';

  @override
  String? modelToViewValue(DateTime? modelValue) {
    final dobAge = accessor.modelToViewValue(modelValue);

    if (dobAge == null || (dobAge.years == 0 && dobAge.months == 0)) {
      existingYear = '';
      existingDays = '';
      return null;
    }

    existingYear = dobAge.years.toString();
    existingDays = dobAge.days.toString();
    int months = dobAge.months;
    return months.toString();
  }

  @override
  DateTime? viewToModelValue(String? viewValue) {
    final months = int.tryParse(viewValue ?? '');
    
    // Validate that months are between 0-11
    if (months != null && (months < 0 || months > 11)) {
      return null; // Return null to indicate invalid value
    }
    
    final dobAge = DigitDOBAge(
        years: int.tryParse(existingYear) ?? 0,
        months: months ?? 0,
        days: int.tryParse(existingDays) ?? 0);
    return accessor.viewToModelValue(dobAge);
  }
}
