import 'package:collection/collection.dart';
import 'package:digit_data_model/data_model.dart';
import 'package:digit_ui_components/digit_components.dart';
import 'package:digit_ui_components/widgets/atoms/digit_divider.dart';
import 'package:digit_ui_components/widgets/atoms/table_cell.dart';
import 'package:digit_ui_components/widgets/molecules/digit_table.dart';
import 'package:flutter/material.dart';
import 'package:registration_delivery/blocs/app_localization.dart';
import 'package:registration_delivery/registration_delivery.dart';
import 'package:registration_delivery/utils/utils.dart';
import 'package:registration_delivery/widgets/table_card/table_card.dart';
import '../../../utils/i18_key_constants.dart' as i18;
import '../../../utils/utils.dart';

// This function builds a table with the given data and headers
Widget buildTableContentVAS(
  DeliverInterventionState deliverInterventionState,
  BuildContext context,
  List<ProductVariantModel>? variant,
  IndividualModel? individualModel,
  HouseholdModel? householdModel,
) {
  // Calculate the current cycle. If deliverInterventionState.cycle is negative, set it to 0.
  final currentCycle =
      deliverInterventionState.cycle >= 0 ? deliverInterventionState.cycle : 0;

  // Calculate the current dose. If deliverInterventionState.dose is negative, set it to 0.
  final currentDose =
      deliverInterventionState.dose >= 0 ? deliverInterventionState.dose : 0;
  final localizations = RegistrationDeliveryLocalization.of(context);

  // Defining a list of table headers for resource popup
  final columnListResource = [
    DigitTableColumn(
      header: localizations.translate(i18.beneficiaryDetails.beneficiaryDose),
      cellValue: 'dose',
      width: 50,
    ),
    DigitTableColumn(
      header:
          localizations.translate(i18.beneficiaryDetails.beneficiaryResources),
      cellValue: 'resources',
      width: 50,
    ),
  ];

  // Calculate the height of the container based on the number of items in the table

  final ProjectTypeModel? projectType = RegistrationDeliverySingleton()
      .selectedProject
      ?.additionalDetails
      ?.additionalProjectType;
  final item =
      projectType?.cycles?[currentCycle - 1].deliveries?[currentDose - 1];
  final productVariants =
      fetchProductVariant(item, individualModel, householdModel)
          ?.productVariants;
  final numRows = productVariants?.length ?? 0;
  const rowHeight = 84;
  const paddingHeight = (spacer2 * 2);
  final containerHeight = (numRows + 1) * rowHeight + (paddingHeight * 2);
  const columnWidth = 100.0;
  const cellHeight = 59.5;

  return Container(
    padding: const EdgeInsets.only(
      left: spacer2,
      bottom: 0,
      right: spacer2,
      top: 0,
    ),
    width: MediaQuery.of(context).size.width / 1.25,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: spacer1),
          child: DigitTableCard(
            topPadding: const EdgeInsets.only(top: 0.0),
            fraction: 2.5,
            element: {
              localizations.translate(
                i18.beneficiaryDetails.beneficiaryAge,
              ): fetchProductVariant(item, individualModel, householdModel)
                          ?.condition !=
                      null
                  ? customFormatAgeRange(fetchProductVariant(
                          item, individualModel, householdModel)!
                      .condition!)
                  : null,
            },
          ),
        ),
        const DigitDivider(),
        const SizedBox(
          height: spacer4,
        ),
        // Build the DigitTable with the data
        if (fetchProductVariant(item, individualModel, householdModel)
                ?.productVariants !=
            null)
          DigitTable(
            enableBorder: false,
            withRowDividers: false,
            withColumnDividers: false,
            showSelectedState: false,
            showPagination: false,
            columns: columnListResource,
            rows: [
              ...fetchProductVariant(item, individualModel, householdModel)!
                  .productVariants!
                  .map(
                (e) {
                  // Retrieve the SKU value for the product variant.
                  final value = variant
                      ?.firstWhereOrNull(
                        (element) => element.id == e.productVariantId,
                      )
                      ?.sku;
                  final quantity = e.quantity;

                  return DigitTableRow(tableRow: [
                    // Display the dose information in the first column if it's the first row,
                    // otherwise, display an empty cell.

                    fetchProductVariant(item, individualModel, householdModel)
                                ?.productVariants
                                ?.indexOf(e) ==
                            0
                        ? DigitTableData(
                            '${localizations.translate(i18.deliverIntervention.dose)} ${deliverInterventionState.dose}',
                            cellKey: 'dose',
                          )
                        : DigitTableData('', cellKey: ''),
                    // Display the SKU value in the second column.
                    DigitTableData(
                      '', // label left empty since we're using widget instead
                      cellKey: 'resources',
                      widget: RichText(
                        text: TextSpan(
                          children: () {
                            final translated =
                                localizations.translate(value.toString());

                            if (translated == 'Blue VAS') {
                              return [
                                const TextSpan(
                                  text: 'VAS - ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                const TextSpan(
                                  text: 'Blue Capsule',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue),
                                ),
                              ];
                            } else if (translated == 'Red VAS') {
                              return [
                                const TextSpan(
                                  text: 'VAS - ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                const TextSpan(
                                  text: 'Red Capsule',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red),
                                ),
                              ];
                            } else {
                              return [
                                TextSpan(
                                  text: translated,
                                  style: const TextStyle(color: Colors.black),
                                ),
                              ];
                            }
                          }(),
                        ),
                      ),
                    )
                  ]);
                },
              ),
            ],
          )
        else
          Text(localizations.translate(i18.common.noProjectSelected))
      ],
    ),
  );
}
