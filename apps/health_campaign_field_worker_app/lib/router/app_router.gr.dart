// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

abstract class _$AppRouter extends RootStackRouter {
  // ignore: unused_element
  _$AppRouter({super.navigatorKey});

  @override
  final Map<String, PageFactory> pagesMap = {
    AcknowledgementRoute.name: (routeData) {
      final args = routeData.argsAs<AcknowledgementRouteArgs>(
          orElse: () => const AcknowledgementRouteArgs());
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: AcknowledgementPage(
          key: args.key,
          appLocalizations: args.appLocalizations,
          isDataRecordSuccess: args.isDataRecordSuccess,
          label: args.label,
          description: args.description,
          descriptionTableData: args.descriptionTableData,
        ),
      );
    },
    AuthenticatedRouteWrapper.name: (routeData) {
      final args = routeData.argsAs<AuthenticatedRouteWrapperArgs>(
          orElse: () => const AuthenticatedRouteWrapperArgs());
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: AuthenticatedPageWrapper(key: args.key),
      );
    },
    BeneficiariesReportRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const BeneficiariesReportPage(),
      );
    },
    BoundarySelectionRoute.name: (routeData) {
      final args = routeData.argsAs<BoundarySelectionRouteArgs>(
          orElse: () => const BoundarySelectionRouteArgs());
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: BoundarySelectionPage(
          key: args.key,
          appLocalizations: args.appLocalizations,
        ),
      );
    },
    CaregiverConsentRoute.name: (routeData) {
      final args = routeData.argsAs<CaregiverConsentRouteArgs>(
          orElse: () => const CaregiverConsentRouteArgs());
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: CaregiverConsentPage(
          key: args.key,
          appLocalizations: args.appLocalizations,
        ),
      );
    },
    CustomAttendanceDateSessionSelectionRoute.name: (routeData) {
      final args =
          routeData.argsAs<CustomAttendanceDateSessionSelectionRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: CustomAttendanceDateSessionSelectionPage(
          registers: args.registers,
          registerID: args.registerID,
          key: args.key,
          appLocalizations: args.appLocalizations,
        ),
      );
    },
    CustomBeneficiaryAcknowledgementRoute.name: (routeData) {
      final args =
          routeData.argsAs<CustomBeneficiaryAcknowledgementRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: CustomBeneficiaryAcknowledgementPage(
          key: args.key,
          appLocalizations: args.appLocalizations,
          acknowledgementType: args.acknowledgementType,
          enableViewHousehold: args.enableViewHousehold,
        ),
      );
    },
    CustomBeneficiaryDetailsRoute.name: (routeData) {
      final args = routeData.argsAs<CustomBeneficiaryDetailsRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: CustomBeneficiaryDetailsPage(
          eligibilityAssessmentType: args.eligibilityAssessmentType,
          key: args.key,
          appLocalizations: args.appLocalizations,
        ),
      );
    },
    CustomBeneficiaryRegistrationWrapperRoute.name: (routeData) {
      final args =
          routeData.argsAs<CustomBeneficiaryRegistrationWrapperRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: WrappedRoute(
            child: CustomBeneficiaryRegistrationWrapperPage(
          key: args.key,
          initialState: args.initialState,
        )),
      );
    },
    CustomBeneficiarySummaryRoute.name: (routeData) {
      final args = routeData.argsAs<CustomBeneficiarySummaryRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: CustomBeneficiarySummaryPage(
          key: args.key,
          appLocalizations: args.appLocalizations,
          name: args.name,
          individualModel: args.individualModel,
        ),
      );
    },
    CustomClosedHouseholdDetailsRoute.name: (routeData) {
      final args = routeData.argsAs<CustomClosedHouseholdDetailsRouteArgs>(
          orElse: () => const CustomClosedHouseholdDetailsRouteArgs());
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: CustomClosedHouseholdDetailsPage(
          key: args.key,
          appLocalizations: args.appLocalizations,
        ),
      );
    },
    CustomClosedHouseholdSummaryRoute.name: (routeData) {
      final args = routeData.argsAs<CustomClosedHouseholdSummaryRouteArgs>(
          orElse: () => const CustomClosedHouseholdSummaryRouteArgs());
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: CustomClosedHouseholdSummaryPage(
          key: args.key,
          appLocalizations: args.appLocalizations,
        ),
      );
    },
    CustomComplaintTypeRoute.name: (routeData) {
      final args = routeData.argsAs<CustomComplaintTypeRouteArgs>(
          orElse: () => const CustomComplaintTypeRouteArgs());
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: CustomComplaintTypePage(
          key: args.key,
          appLocalizations: args.appLocalizations,
        ),
      );
    },
    CustomComplaintsDetailsRoute.name: (routeData) {
      final args = routeData.argsAs<CustomComplaintsDetailsRouteArgs>(
          orElse: () => const CustomComplaintsDetailsRouteArgs());
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: CustomComplaintsDetailsPage(
          key: args.key,
          appLocalizations: args.appLocalizations,
        ),
      );
    },
    CustomComplaintsInboxSearchRoute.name: (routeData) {
      final args = routeData.argsAs<CustomComplaintsInboxSearchRouteArgs>(
          orElse: () => const CustomComplaintsInboxSearchRouteArgs());
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: CustomComplaintsInboxSearchPage(
          key: args.key,
          appLocalizations: args.appLocalizations,
        ),
      );
    },
    CustomDeliverInterventionRoute.name: (routeData) {
      final args = routeData.argsAs<CustomDeliverInterventionRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: CustomDeliverInterventionPage(
          key: args.key,
          appLocalizations: args.appLocalizations,
          eligibilityAssessmentType: args.eligibilityAssessmentType,
          isEditing: args.isEditing,
        ),
      );
    },
    CustomDeliverySummaryRoute.name: (routeData) {
      final args = routeData.argsAs<CustomDeliverySummaryRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: CustomDeliverySummaryPage(
          key: args.key,
          appLocalizations: args.appLocalizations,
          eligibilityAssessmentType: args.eligibilityAssessmentType,
          task: args.task,
        ),
      );
    },
    CustomDoseAdministeredRoute.name: (routeData) {
      final args = routeData.argsAs<CustomDoseAdministeredRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: CustomDoseAdministeredPage(
          key: args.key,
          appLocalizations: args.appLocalizations,
          eligibilityAssessmentType: args.eligibilityAssessmentType,
        ),
      );
    },
    CustomFacilitySelectionSMCRoute.name: (routeData) {
      final args = routeData.argsAs<CustomFacilitySelectionSMCRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: CustomFacilitySelectionSMCPage(
          key: args.key,
          appLocalizations: args.appLocalizations,
          facilities: args.facilities,
        ),
      );
    },
    CustomHFCreateReferralWrapperRoute.name: (routeData) {
      final args = routeData.argsAs<CustomHFCreateReferralWrapperRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: CustomHFCreateReferralWrapperPage(
          key: args.key,
          projectId: args.projectId,
          viewOnly: args.viewOnly,
          referralReconciliation: args.referralReconciliation,
          cycles: args.cycles,
        ),
      );
    },
    CustomHouseHoldDetailsRoute.name: (routeData) {
      final args = routeData.argsAs<CustomHouseHoldDetailsRouteArgs>(
          orElse: () => const CustomHouseHoldDetailsRouteArgs());
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: CustomHouseHoldDetailsPage(
          key: args.key,
          appLocalizations: args.appLocalizations,
        ),
      );
    },
    CustomHouseholdAcknowledgementRoute.name: (routeData) {
      final args = routeData.argsAs<CustomHouseholdAcknowledgementRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: CustomHouseholdAcknowledgementPage(
          key: args.key,
          appLocalizations: args.appLocalizations,
          enableViewHousehold: args.enableViewHousehold,
          eligibilityAssessmentType: args.eligibilityAssessmentType,
        ),
      );
    },
    CustomHouseholdAcknowledgementSMCRoute.name: (routeData) {
      final args = routeData.argsAs<CustomHouseholdAcknowledgementSMCRouteArgs>(
          orElse: () => const CustomHouseholdAcknowledgementSMCRouteArgs());
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: CustomHouseholdAcknowledgementSMCPage(
          key: args.key,
          appLocalizations: args.appLocalizations,
          enableViewHousehold: args.enableViewHousehold,
          isReferral: args.isReferral,
        ),
      );
    },
    CustomHouseholdLocationRoute.name: (routeData) {
      final args = routeData.argsAs<CustomHouseholdLocationRouteArgs>(
          orElse: () => const CustomHouseholdLocationRouteArgs());
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: CustomHouseholdLocationPage(
          key: args.key,
          appLocalizations: args.appLocalizations,
        ),
      );
    },
    CustomHouseholdOverviewRoute.name: (routeData) {
      final args = routeData.argsAs<CustomHouseholdOverviewRouteArgs>(
          orElse: () => const CustomHouseholdOverviewRouteArgs());
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: CustomHouseholdOverviewPage(
          key: args.key,
          appLocalizations: args.appLocalizations,
        ),
      );
    },
    CustomIndividualDetailsRoute.name: (routeData) {
      final args = routeData.argsAs<CustomIndividualDetailsRouteArgs>(
          orElse: () => const CustomIndividualDetailsRouteArgs());
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: CustomIndividualDetailsPage(
          key: args.key,
          appLocalizations: args.appLocalizations,
          isHeadOfHousehold: args.isHeadOfHousehold,
        ),
      );
    },
    CustomInventoryAcknowledgementRoute.name: (routeData) {
      final args = routeData.argsAs<CustomInventoryAcknowledgementRouteArgs>(
          orElse: () => const CustomInventoryAcknowledgementRouteArgs());
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: CustomInventoryAcknowledgementPage(
          key: args.key,
          appLocalizations: args.appLocalizations,
          isDataRecordSuccess: args.isDataRecordSuccess,
          label: args.label,
          description: args.description,
          descriptionTableData: args.descriptionTableData,
        ),
      );
    },
    CustomInventoryFacilitySelectionRoute.name: (routeData) {
      final args =
          routeData.argsAs<CustomInventoryFacilitySelectionRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: CustomInventoryFacilitySelectionPage(
          key: args.key,
          appLocalizations: args.appLocalizations,
          facilities: args.facilities,
        ),
      );
    },
    CustomInventoryFacilitySelectionSMCRoute.name: (routeData) {
      final args =
          routeData.argsAs<CustomInventoryFacilitySelectionSMCRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: CustomInventoryFacilitySelectionSMCPage(
          key: args.key,
          appLocalizations: args.appLocalizations,
          facilities: args.facilities,
        ),
      );
    },
    CustomInventoryReportDetailsRoute.name: (routeData) {
      final args = routeData.argsAs<CustomInventoryReportDetailsRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: CustomInventoryReportDetailsPage(
          key: args.key,
          appLocalizations: args.appLocalizations,
          reportType: args.reportType,
        ),
      );
    },
    CustomInventoryReportSelectionRoute.name: (routeData) {
      final args = routeData.argsAs<CustomInventoryReportSelectionRouteArgs>(
          orElse: () => const CustomInventoryReportSelectionRouteArgs());
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: CustomInventoryReportSelectionPage(
          key: args.key,
          appLocalizations: args.appLocalizations,
        ),
      );
    },
    CustomManageAttendanceRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const CustomManageAttendancePage(),
      );
    },
    CustomManageStocksRoute.name: (routeData) {
      final args = routeData.argsAs<CustomManageStocksRouteArgs>(
          orElse: () => const CustomManageStocksRouteArgs());
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: CustomManageStocksPage(
          key: args.key,
          appLocalizations: args.appLocalizations,
        ),
      );
    },
    CustomMarkAttendanceRoute.name: (routeData) {
      final args = routeData.argsAs<CustomMarkAttendanceRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: CustomMarkAttendancePage(
          attendees: args.attendees,
          registerId: args.registerId,
          tenantId: args.tenantId,
          dateTime: args.dateTime,
          entryTime: args.entryTime,
          exitTime: args.exitTime,
          session: args.session,
          key: args.key,
          appLocalizations: args.appLocalizations,
        ),
      );
    },
    CustomRecordReferralDetailsRoute.name: (routeData) {
      final args = routeData.argsAs<CustomRecordReferralDetailsRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: CustomRecordReferralDetailsPage(
          key: args.key,
          appLocalizations: args.appLocalizations,
          isEditing: args.isEditing,
          projectId: args.projectId,
          cycles: args.cycles,
        ),
      );
    },
    CustomRecordStockWrapperRoute.name: (routeData) {
      final args = routeData.argsAs<CustomRecordStockWrapperRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: WrappedRoute(
            child: CustomRecordStockWrapperPage(
          key: args.key,
          type: args.type,
        )),
      );
    },
    CustomReferBeneficiarySMCRoute.name: (routeData) {
      final args = routeData.argsAs<CustomReferBeneficiarySMCRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: CustomReferBeneficiarySMCPage(
          key: args.key,
          appLocalizations: args.appLocalizations,
          isEditing: args.isEditing,
          projectBeneficiaryClientRefId: args.projectBeneficiaryClientRefId,
          individual: args.individual,
          isReadministrationUnSuccessful: args.isReadministrationUnSuccessful,
          quantityWasted: args.quantityWasted,
          productVariantId: args.productVariantId,
          referralReasons: args.referralReasons,
        ),
      );
    },
    CustomReferralFacilityRoute.name: (routeData) {
      final args = routeData.argsAs<CustomReferralFacilityRouteArgs>(
          orElse: () => const CustomReferralFacilityRouteArgs());
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: CustomReferralFacilityPage(
          key: args.key,
          appLocalizations: args.appLocalizations,
          isEditing: args.isEditing,
        ),
      );
    },
    CustomReferralReasonChecklistRoute.name: (routeData) {
      final args = routeData.argsAs<CustomReferralReasonChecklistRouteArgs>(
          orElse: () => const CustomReferralReasonChecklistRouteArgs());
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: CustomReferralReasonChecklistPage(
          key: args.key,
          referralClientRefId: args.referralClientRefId,
          appLocalizations: args.appLocalizations,
        ),
      );
    },
    CustomReferralReasonChecklistPreviewRoute.name: (routeData) {
      final args =
          routeData.argsAs<CustomReferralReasonChecklistPreviewRouteArgs>(
              orElse: () =>
                  const CustomReferralReasonChecklistPreviewRouteArgs());
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: CustomReferralReasonChecklistPreviewPage(
          key: args.key,
          appLocalizations: args.appLocalizations,
        ),
      );
    },
    CustomReferralReconProjectFacilitySelectionRoute.name: (routeData) {
      final args = routeData
          .argsAs<CustomReferralReconProjectFacilitySelectionRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: CustomReferralReconProjectFacilitySelectionPage(
          key: args.key,
          appLocalizations: args.appLocalizations,
          projectFacilities: args.projectFacilities,
        ),
      );
    },
    CustomRegistrationDeliveryWrapperRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const CustomRegistrationDeliveryWrapperPage(),
      );
    },
    CustomSearchBeneficiaryRoute.name: (routeData) {
      final args = routeData.argsAs<CustomSearchBeneficiaryRouteArgs>(
          orElse: () => const CustomSearchBeneficiaryRouteArgs());
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: CustomSearchBeneficiaryPage(
          key: args.key,
          appLocalizations: args.appLocalizations,
        ),
      );
    },
    CustomSearchReferralReconciliationsRoute.name: (routeData) {
      final args =
          routeData.argsAs<CustomSearchReferralReconciliationsRouteArgs>(
              orElse: () =>
                  const CustomSearchReferralReconciliationsRouteArgs());
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: CustomSearchReferralReconciliationsPage(
          key: args.key,
          appLocalizations: args.appLocalizations,
        ),
      );
    },
    CustomSideEffectsRoute.name: (routeData) {
      final args = routeData.argsAs<CustomSideEffectsRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: CustomSideEffectsPage(
          key: args.key,
          appLocalizations: args.appLocalizations,
          tasks: args.tasks,
          isEditing: args.isEditing,
        ),
      );
    },
    CustomSplashAcknowledgementRoute.name: (routeData) {
      final args = routeData.argsAs<CustomSplashAcknowledgementRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: CustomSplashAcknowledgementPage(
          key: args.key,
          appLocalizations: args.appLocalizations,
          enableBackToSearch: args.enableBackToSearch,
          eligibilityAssessmentType: args.eligibilityAssessmentType,
          enableRouteToZeroDose: args.enableRouteToZeroDose,
          task: args.task,
        ),
      );
    },
    CustomStockDetailsRoute.name: (routeData) {
      final args = routeData.argsAs<CustomStockDetailsRouteArgs>(
          orElse: () => const CustomStockDetailsRouteArgs());
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: CustomStockDetailsPage(
          key: args.key,
          appLocalizations: args.appLocalizations,
        ),
      );
    },
    CustomStockReconciliationRoute.name: (routeData) {
      final args = routeData.argsAs<CustomStockReconciliationRouteArgs>(
          orElse: () => const CustomStockReconciliationRouteArgs());
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: CustomStockReconciliationPage(
          key: args.key,
          appLocalizations: args.appLocalizations,
        ),
      );
    },
    CustomSummaryRoute.name: (routeData) {
      final args = routeData.argsAs<CustomSummaryRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: CustomSummaryPage(
          key: args.key,
          appLocalizations: args.appLocalizations,
          name: args.name,
        ),
      );
    },
    CustomSummaryReportRoute.name: (routeData) {
      final args = routeData.argsAs<CustomSummaryReportRouteArgs>(
          orElse: () => const CustomSummaryReportRouteArgs());
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: CustomSummaryReportPage(
          key: args.key,
          appLocalizations: args.appLocalizations,
        ),
      );
    },
    CustomSurveyFormAcknowledgementRoute.name: (routeData) {
      final args = routeData.argsAs<CustomSurveyFormAcknowledgementRouteArgs>(
          orElse: () => const CustomSurveyFormAcknowledgementRouteArgs());
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: CustomSurveyFormAcknowledgementPage(
          key: args.key,
          appLocalizations: args.appLocalizations,
          isDataRecordSuccess: args.isDataRecordSuccess,
          label: args.label,
          description: args.description,
          descriptionTableData: args.descriptionTableData,
        ),
      );
    },
    CustomSurveyFormBoundaryViewRoute.name: (routeData) {
      final args = routeData.argsAs<CustomSurveyFormBoundaryViewRouteArgs>(
          orElse: () => const CustomSurveyFormBoundaryViewRouteArgs());
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: CustomSurveyFormBoundaryViewPage(
          key: args.key,
          appLocalizations: args.appLocalizations,
        ),
      );
    },
    CustomSurveyFormPreviewRoute.name: (routeData) {
      final args = routeData.argsAs<CustomSurveyFormPreviewRouteArgs>(
          orElse: () => const CustomSurveyFormPreviewRouteArgs());
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: CustomSurveyFormPreviewPage(
          key: args.key,
          appLocalizations: args.appLocalizations,
        ),
      );
    },
    CustomSurveyFormViewRoute.name: (routeData) {
      final args = routeData.argsAs<CustomSurveyFormViewRouteArgs>(
          orElse: () => const CustomSurveyFormViewRouteArgs());
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: CustomSurveyFormViewPage(
          key: args.key,
          appLocalizations: args.appLocalizations,
        ),
      );
    },
    CustomSurveyFormWrapperRoute.name: (routeData) {
      final args = routeData.argsAs<CustomSurveyFormWrapperRouteArgs>(
          orElse: () => const CustomSurveyFormWrapperRouteArgs());
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: CustomSurveyFormWrapperPage(
          key: args.key,
          isEditing: args.isEditing,
        ),
      );
    },
    CustomSurveyformRoute.name: (routeData) {
      final args = routeData.argsAs<CustomSurveyformRouteArgs>(
          orElse: () => const CustomSurveyformRouteArgs());
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: CustomSurveyformPage(
          key: args.key,
          appLocalizations: args.appLocalizations,
        ),
      );
    },
    CustomWarehouseDetailsRoute.name: (routeData) {
      final args = routeData.argsAs<CustomWarehouseDetailsRouteArgs>(
          orElse: () => const CustomWarehouseDetailsRouteArgs());
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: CustomWarehouseDetailsPage(
          key: args.key,
          appLocalizations: args.appLocalizations,
        ),
      );
    },
    DigitScannerRoute.name: (routeData) {
      final args = routeData.argsAs<DigitScannerRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: DigitScannerPage(
          key: args.key,
          appLocalizations: args.appLocalizations,
          quantity: args.quantity,
          isGS1code: args.isGS1code,
          singleValue: args.singleValue,
          isEditEnabled: args.isEditEnabled,
        ),
      );
    },
    EligibilityChecklistViewRoute.name: (routeData) {
      final args = routeData.argsAs<EligibilityChecklistViewRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: EligibilityChecklistViewPage(
          key: args.key,
          referralClientRefId: args.referralClientRefId,
          individual: args.individual,
          projectBeneficiaryClientReferenceId:
              args.projectBeneficiaryClientReferenceId,
          eligibilityAssessmentType: args.eligibilityAssessmentType,
          appLocalizations: args.appLocalizations,
        ),
      );
    },
    HomeRoute.name: (routeData) {
      final args =
          routeData.argsAs<HomeRouteArgs>(orElse: () => const HomeRouteArgs());
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: HomePage(
          key: args.key,
          appLocalizations: args.appLocalizations,
        ),
      );
    },
    LanguageSelectionRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const LanguageSelectionPage(),
      );
    },
    LoginRoute.name: (routeData) {
      final args = routeData.argsAs<LoginRouteArgs>(
          orElse: () => const LoginRouteArgs());
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: LoginPage(
          key: args.key,
          appLocalizations: args.appLocalizations,
        ),
      );
    },
    ProfileRoute.name: (routeData) {
      final args = routeData.argsAs<ProfileRouteArgs>(
          orElse: () => const ProfileRouteArgs());
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: ProfilePage(
          key: args.key,
          appLocalizations: args.appLocalizations,
        ),
      );
    },
    ProjectFacilitySelectionRoute.name: (routeData) {
      final args = routeData.argsAs<ProjectFacilitySelectionRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: ProjectFacilitySelectionPage(
          key: args.key,
          projectFacilities: args.projectFacilities,
        ),
      );
    },
    ProjectSelectionRoute.name: (routeData) {
      final args = routeData.argsAs<ProjectSelectionRouteArgs>(
          orElse: () => const ProjectSelectionRouteArgs());
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: ProjectSelectionPage(
          key: args.key,
          appLocalizations: args.appLocalizations,
        ),
      );
    },
    QRScannerRoute.name: (routeData) {
      final args = routeData.argsAs<QRScannerRouteArgs>(
          orElse: () => const QRScannerRouteArgs());
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: QRScannerPage(
          key: args.key,
          appLocalizations: args.appLocalizations,
        ),
      );
    },
    RecordRedoseRoute.name: (routeData) {
      final args = routeData.argsAs<RecordRedoseRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: RecordRedosePage(
          key: args.key,
          appLocalizations: args.appLocalizations,
          isEditing: args.isEditing,
          tasks: args.tasks,
        ),
      );
    },
    UnauthenticatedRouteWrapper.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const UnauthenticatedPageWrapper(),
      );
    },
    UserQRDetailsRoute.name: (routeData) {
      final args = routeData.argsAs<UserQRDetailsRouteArgs>(
          orElse: () => const UserQRDetailsRouteArgs());
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: UserQRDetailsPage(
          key: args.key,
          appLocalizations: args.appLocalizations,
        ),
      );
    },
    VaccineSelectionRoute.name: (routeData) {
      final args = routeData.argsAs<VaccineSelectionRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: VaccineSelectionPage(
          key: args.key,
          appLocalizations: args.appLocalizations,
          isAdministration: args.isAdministration,
          eligibilityAssessmentType: args.eligibilityAssessmentType,
          isChecklistAssessmentDone: args.isChecklistAssessmentDone,
          projectBeneficiaryClientReferenceId:
              args.projectBeneficiaryClientReferenceId,
          individual: args.individual,
          task: args.task,
          hasSideEffects: args.hasSideEffects,
          sideEffect: args.sideEffect,
          isZeroDoseAlreadyDone: args.isZeroDoseAlreadyDone,
        ),
      );
    },
    ZeroDoseCheckRoute.name: (routeData) {
      final args = routeData.argsAs<ZeroDoseCheckRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: ZeroDoseCheckPage(
          key: args.key,
          appLocalizations: args.appLocalizations,
          eligibilityAssessmentType: args.eligibilityAssessmentType,
          isAdministration: args.isAdministration,
          isEditing: args.isEditing,
          isChecklistAssessmentDone: args.isChecklistAssessmentDone,
          projectBeneficiaryClientReferenceId:
              args.projectBeneficiaryClientReferenceId,
          individual: args.individual,
          hasSideEffects: args.hasSideEffects,
          isRefused: args.isRefused,
          sideEffect: args.sideEffect,
          task: args.task,
        ),
      );
    },
    ...InventoryRoute().pagesMap,
    ...RegistrationDeliveryRoute().pagesMap,
    ...ReferralReconciliationRoute().pagesMap,
    ...AttendanceRoute().pagesMap,
    ...ComplaintsRoute().pagesMap,
    ...SurveyFormRoute().pagesMap,
    ...ClosedHouseholdPackageRoute().pagesMap,
  };
}

/// generated route for
/// [AcknowledgementPage]
class AcknowledgementRoute extends PageRouteInfo<AcknowledgementRouteArgs> {
  AcknowledgementRoute({
    Key? key,
    AppLocalizations? appLocalizations,
    bool isDataRecordSuccess = false,
    String? label,
    String? description,
    Map<String, dynamic>? descriptionTableData,
    List<PageRouteInfo>? children,
  }) : super(
          AcknowledgementRoute.name,
          args: AcknowledgementRouteArgs(
            key: key,
            appLocalizations: appLocalizations,
            isDataRecordSuccess: isDataRecordSuccess,
            label: label,
            description: description,
            descriptionTableData: descriptionTableData,
          ),
          initialChildren: children,
        );

  static const String name = 'AcknowledgementRoute';

  static const PageInfo<AcknowledgementRouteArgs> page =
      PageInfo<AcknowledgementRouteArgs>(name);
}

class AcknowledgementRouteArgs {
  const AcknowledgementRouteArgs({
    this.key,
    this.appLocalizations,
    this.isDataRecordSuccess = false,
    this.label,
    this.description,
    this.descriptionTableData,
  });

  final Key? key;

  final AppLocalizations? appLocalizations;

  final bool isDataRecordSuccess;

  final String? label;

  final String? description;

  final Map<String, dynamic>? descriptionTableData;

  @override
  String toString() {
    return 'AcknowledgementRouteArgs{key: $key, appLocalizations: $appLocalizations, isDataRecordSuccess: $isDataRecordSuccess, label: $label, description: $description, descriptionTableData: $descriptionTableData}';
  }
}

/// generated route for
/// [AuthenticatedPageWrapper]
class AuthenticatedRouteWrapper
    extends PageRouteInfo<AuthenticatedRouteWrapperArgs> {
  AuthenticatedRouteWrapper({
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
          AuthenticatedRouteWrapper.name,
          args: AuthenticatedRouteWrapperArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'AuthenticatedRouteWrapper';

  static const PageInfo<AuthenticatedRouteWrapperArgs> page =
      PageInfo<AuthenticatedRouteWrapperArgs>(name);
}

class AuthenticatedRouteWrapperArgs {
  const AuthenticatedRouteWrapperArgs({this.key});

  final Key? key;

  @override
  String toString() {
    return 'AuthenticatedRouteWrapperArgs{key: $key}';
  }
}

/// generated route for
/// [BeneficiariesReportPage]
class BeneficiariesReportRoute extends PageRouteInfo<void> {
  const BeneficiariesReportRoute({List<PageRouteInfo>? children})
      : super(
          BeneficiariesReportRoute.name,
          initialChildren: children,
        );

  static const String name = 'BeneficiariesReportRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [BoundarySelectionPage]
class BoundarySelectionRoute extends PageRouteInfo<BoundarySelectionRouteArgs> {
  BoundarySelectionRoute({
    Key? key,
    AppLocalizations? appLocalizations,
    List<PageRouteInfo>? children,
  }) : super(
          BoundarySelectionRoute.name,
          args: BoundarySelectionRouteArgs(
            key: key,
            appLocalizations: appLocalizations,
          ),
          initialChildren: children,
        );

  static const String name = 'BoundarySelectionRoute';

  static const PageInfo<BoundarySelectionRouteArgs> page =
      PageInfo<BoundarySelectionRouteArgs>(name);
}

class BoundarySelectionRouteArgs {
  const BoundarySelectionRouteArgs({
    this.key,
    this.appLocalizations,
  });

  final Key? key;

  final AppLocalizations? appLocalizations;

  @override
  String toString() {
    return 'BoundarySelectionRouteArgs{key: $key, appLocalizations: $appLocalizations}';
  }
}

/// generated route for
/// [CaregiverConsentPage]
class CaregiverConsentRoute extends PageRouteInfo<CaregiverConsentRouteArgs> {
  CaregiverConsentRoute({
    Key? key,
    RegistrationDeliveryLocalization? appLocalizations,
    List<PageRouteInfo>? children,
  }) : super(
          CaregiverConsentRoute.name,
          args: CaregiverConsentRouteArgs(
            key: key,
            appLocalizations: appLocalizations,
          ),
          initialChildren: children,
        );

  static const String name = 'CaregiverConsentRoute';

  static const PageInfo<CaregiverConsentRouteArgs> page =
      PageInfo<CaregiverConsentRouteArgs>(name);
}

class CaregiverConsentRouteArgs {
  const CaregiverConsentRouteArgs({
    this.key,
    this.appLocalizations,
  });

  final Key? key;

  final RegistrationDeliveryLocalization? appLocalizations;

  @override
  String toString() {
    return 'CaregiverConsentRouteArgs{key: $key, appLocalizations: $appLocalizations}';
  }
}

/// generated route for
/// [CustomAttendanceDateSessionSelectionPage]
class CustomAttendanceDateSessionSelectionRoute
    extends PageRouteInfo<CustomAttendanceDateSessionSelectionRouteArgs> {
  CustomAttendanceDateSessionSelectionRoute({
    required List<AttendanceRegisterModel> registers,
    required String registerID,
    Key? key,
    AppLocalizations? appLocalizations,
    List<PageRouteInfo>? children,
  }) : super(
          CustomAttendanceDateSessionSelectionRoute.name,
          args: CustomAttendanceDateSessionSelectionRouteArgs(
            registers: registers,
            registerID: registerID,
            key: key,
            appLocalizations: appLocalizations,
          ),
          initialChildren: children,
        );

  static const String name = 'CustomAttendanceDateSessionSelectionRoute';

  static const PageInfo<CustomAttendanceDateSessionSelectionRouteArgs> page =
      PageInfo<CustomAttendanceDateSessionSelectionRouteArgs>(name);
}

class CustomAttendanceDateSessionSelectionRouteArgs {
  const CustomAttendanceDateSessionSelectionRouteArgs({
    required this.registers,
    required this.registerID,
    this.key,
    this.appLocalizations,
  });

  final List<AttendanceRegisterModel> registers;

  final String registerID;

  final Key? key;

  final AppLocalizations? appLocalizations;

  @override
  String toString() {
    return 'CustomAttendanceDateSessionSelectionRouteArgs{registers: $registers, registerID: $registerID, key: $key, appLocalizations: $appLocalizations}';
  }
}

/// generated route for
/// [CustomBeneficiaryAcknowledgementPage]
class CustomBeneficiaryAcknowledgementRoute
    extends PageRouteInfo<CustomBeneficiaryAcknowledgementRouteArgs> {
  CustomBeneficiaryAcknowledgementRoute({
    Key? key,
    RegistrationDeliveryLocalization? appLocalizations,
    required AcknowledgementType acknowledgementType,
    bool? enableViewHousehold,
    List<PageRouteInfo>? children,
  }) : super(
          CustomBeneficiaryAcknowledgementRoute.name,
          args: CustomBeneficiaryAcknowledgementRouteArgs(
            key: key,
            appLocalizations: appLocalizations,
            acknowledgementType: acknowledgementType,
            enableViewHousehold: enableViewHousehold,
          ),
          initialChildren: children,
        );

  static const String name = 'CustomBeneficiaryAcknowledgementRoute';

  static const PageInfo<CustomBeneficiaryAcknowledgementRouteArgs> page =
      PageInfo<CustomBeneficiaryAcknowledgementRouteArgs>(name);
}

class CustomBeneficiaryAcknowledgementRouteArgs {
  const CustomBeneficiaryAcknowledgementRouteArgs({
    this.key,
    this.appLocalizations,
    required this.acknowledgementType,
    this.enableViewHousehold,
  });

  final Key? key;

  final RegistrationDeliveryLocalization? appLocalizations;

  final AcknowledgementType acknowledgementType;

  final bool? enableViewHousehold;

  @override
  String toString() {
    return 'CustomBeneficiaryAcknowledgementRouteArgs{key: $key, appLocalizations: $appLocalizations, acknowledgementType: $acknowledgementType, enableViewHousehold: $enableViewHousehold}';
  }
}

/// generated route for
/// [CustomBeneficiaryDetailsPage]
class CustomBeneficiaryDetailsRoute
    extends PageRouteInfo<CustomBeneficiaryDetailsRouteArgs> {
  CustomBeneficiaryDetailsRoute({
    required EligibilityAssessmentType eligibilityAssessmentType,
    Key? key,
    RegistrationDeliveryLocalization? appLocalizations,
    List<PageRouteInfo>? children,
  }) : super(
          CustomBeneficiaryDetailsRoute.name,
          args: CustomBeneficiaryDetailsRouteArgs(
            eligibilityAssessmentType: eligibilityAssessmentType,
            key: key,
            appLocalizations: appLocalizations,
          ),
          initialChildren: children,
        );

  static const String name = 'CustomBeneficiaryDetailsRoute';

  static const PageInfo<CustomBeneficiaryDetailsRouteArgs> page =
      PageInfo<CustomBeneficiaryDetailsRouteArgs>(name);
}

class CustomBeneficiaryDetailsRouteArgs {
  const CustomBeneficiaryDetailsRouteArgs({
    required this.eligibilityAssessmentType,
    this.key,
    this.appLocalizations,
  });

  final EligibilityAssessmentType eligibilityAssessmentType;

  final Key? key;

  final RegistrationDeliveryLocalization? appLocalizations;

  @override
  String toString() {
    return 'CustomBeneficiaryDetailsRouteArgs{eligibilityAssessmentType: $eligibilityAssessmentType, key: $key, appLocalizations: $appLocalizations}';
  }
}

/// generated route for
/// [CustomBeneficiaryRegistrationWrapperPage]
class CustomBeneficiaryRegistrationWrapperRoute
    extends PageRouteInfo<CustomBeneficiaryRegistrationWrapperRouteArgs> {
  CustomBeneficiaryRegistrationWrapperRoute({
    Key? key,
    required BeneficiaryRegistrationState initialState,
    List<PageRouteInfo>? children,
  }) : super(
          CustomBeneficiaryRegistrationWrapperRoute.name,
          args: CustomBeneficiaryRegistrationWrapperRouteArgs(
            key: key,
            initialState: initialState,
          ),
          initialChildren: children,
        );

  static const String name = 'CustomBeneficiaryRegistrationWrapperRoute';

  static const PageInfo<CustomBeneficiaryRegistrationWrapperRouteArgs> page =
      PageInfo<CustomBeneficiaryRegistrationWrapperRouteArgs>(name);
}

class CustomBeneficiaryRegistrationWrapperRouteArgs {
  const CustomBeneficiaryRegistrationWrapperRouteArgs({
    this.key,
    required this.initialState,
  });

  final Key? key;

  final BeneficiaryRegistrationState initialState;

  @override
  String toString() {
    return 'CustomBeneficiaryRegistrationWrapperRouteArgs{key: $key, initialState: $initialState}';
  }
}

/// generated route for
/// [CustomBeneficiarySummaryPage]
class CustomBeneficiarySummaryRoute
    extends PageRouteInfo<CustomBeneficiarySummaryRouteArgs> {
  CustomBeneficiarySummaryRoute({
    Key? key,
    RegistrationDeliveryLocalization? appLocalizations,
    required dynamic name,
    required IndividualModel individualModel,
    List<PageRouteInfo>? children,
  }) : super(
          CustomBeneficiarySummaryRoute.name,
          args: CustomBeneficiarySummaryRouteArgs(
            key: key,
            appLocalizations: appLocalizations,
            name: name,
            individualModel: individualModel,
          ),
          initialChildren: children,
        );

  static const String name = 'CustomBeneficiarySummaryRoute';

  static const PageInfo<CustomBeneficiarySummaryRouteArgs> page =
      PageInfo<CustomBeneficiarySummaryRouteArgs>(name);
}

class CustomBeneficiarySummaryRouteArgs {
  const CustomBeneficiarySummaryRouteArgs({
    this.key,
    this.appLocalizations,
    required this.name,
    required this.individualModel,
  });

  final Key? key;

  final RegistrationDeliveryLocalization? appLocalizations;

  final dynamic name;

  final IndividualModel individualModel;

  @override
  String toString() {
    return 'CustomBeneficiarySummaryRouteArgs{key: $key, appLocalizations: $appLocalizations, name: $name, individualModel: $individualModel}';
  }
}

/// generated route for
/// [CustomClosedHouseholdDetailsPage]
class CustomClosedHouseholdDetailsRoute
    extends PageRouteInfo<CustomClosedHouseholdDetailsRouteArgs> {
  CustomClosedHouseholdDetailsRoute({
    Key? key,
    ClosedHouseholdLocalization? appLocalizations,
    List<PageRouteInfo>? children,
  }) : super(
          CustomClosedHouseholdDetailsRoute.name,
          args: CustomClosedHouseholdDetailsRouteArgs(
            key: key,
            appLocalizations: appLocalizations,
          ),
          initialChildren: children,
        );

  static const String name = 'CustomClosedHouseholdDetailsRoute';

  static const PageInfo<CustomClosedHouseholdDetailsRouteArgs> page =
      PageInfo<CustomClosedHouseholdDetailsRouteArgs>(name);
}

class CustomClosedHouseholdDetailsRouteArgs {
  const CustomClosedHouseholdDetailsRouteArgs({
    this.key,
    this.appLocalizations,
  });

  final Key? key;

  final ClosedHouseholdLocalization? appLocalizations;

  @override
  String toString() {
    return 'CustomClosedHouseholdDetailsRouteArgs{key: $key, appLocalizations: $appLocalizations}';
  }
}

/// generated route for
/// [CustomClosedHouseholdSummaryPage]
class CustomClosedHouseholdSummaryRoute
    extends PageRouteInfo<CustomClosedHouseholdSummaryRouteArgs> {
  CustomClosedHouseholdSummaryRoute({
    Key? key,
    ClosedHouseholdLocalization? appLocalizations,
    List<PageRouteInfo>? children,
  }) : super(
          CustomClosedHouseholdSummaryRoute.name,
          args: CustomClosedHouseholdSummaryRouteArgs(
            key: key,
            appLocalizations: appLocalizations,
          ),
          initialChildren: children,
        );

  static const String name = 'CustomClosedHouseholdSummaryRoute';

  static const PageInfo<CustomClosedHouseholdSummaryRouteArgs> page =
      PageInfo<CustomClosedHouseholdSummaryRouteArgs>(name);
}

class CustomClosedHouseholdSummaryRouteArgs {
  const CustomClosedHouseholdSummaryRouteArgs({
    this.key,
    this.appLocalizations,
  });

  final Key? key;

  final ClosedHouseholdLocalization? appLocalizations;

  @override
  String toString() {
    return 'CustomClosedHouseholdSummaryRouteArgs{key: $key, appLocalizations: $appLocalizations}';
  }
}

/// generated route for
/// [CustomComplaintTypePage]
class CustomComplaintTypeRoute
    extends PageRouteInfo<CustomComplaintTypeRouteArgs> {
  CustomComplaintTypeRoute({
    Key? key,
    AppLocalizations? appLocalizations,
    List<PageRouteInfo>? children,
  }) : super(
          CustomComplaintTypeRoute.name,
          args: CustomComplaintTypeRouteArgs(
            key: key,
            appLocalizations: appLocalizations,
          ),
          initialChildren: children,
        );

  static const String name = 'CustomComplaintTypeRoute';

  static const PageInfo<CustomComplaintTypeRouteArgs> page =
      PageInfo<CustomComplaintTypeRouteArgs>(name);
}

class CustomComplaintTypeRouteArgs {
  const CustomComplaintTypeRouteArgs({
    this.key,
    this.appLocalizations,
  });

  final Key? key;

  final AppLocalizations? appLocalizations;

  @override
  String toString() {
    return 'CustomComplaintTypeRouteArgs{key: $key, appLocalizations: $appLocalizations}';
  }
}

/// generated route for
/// [CustomComplaintsDetailsPage]
class CustomComplaintsDetailsRoute
    extends PageRouteInfo<CustomComplaintsDetailsRouteArgs> {
  CustomComplaintsDetailsRoute({
    Key? key,
    AppLocalizations? appLocalizations,
    List<PageRouteInfo>? children,
  }) : super(
          CustomComplaintsDetailsRoute.name,
          args: CustomComplaintsDetailsRouteArgs(
            key: key,
            appLocalizations: appLocalizations,
          ),
          initialChildren: children,
        );

  static const String name = 'CustomComplaintsDetailsRoute';

  static const PageInfo<CustomComplaintsDetailsRouteArgs> page =
      PageInfo<CustomComplaintsDetailsRouteArgs>(name);
}

class CustomComplaintsDetailsRouteArgs {
  const CustomComplaintsDetailsRouteArgs({
    this.key,
    this.appLocalizations,
  });

  final Key? key;

  final AppLocalizations? appLocalizations;

  @override
  String toString() {
    return 'CustomComplaintsDetailsRouteArgs{key: $key, appLocalizations: $appLocalizations}';
  }
}

/// generated route for
/// [CustomComplaintsInboxSearchPage]
class CustomComplaintsInboxSearchRoute
    extends PageRouteInfo<CustomComplaintsInboxSearchRouteArgs> {
  CustomComplaintsInboxSearchRoute({
    Key? key,
    ComplaintsLocalization? appLocalizations,
    List<PageRouteInfo>? children,
  }) : super(
          CustomComplaintsInboxSearchRoute.name,
          args: CustomComplaintsInboxSearchRouteArgs(
            key: key,
            appLocalizations: appLocalizations,
          ),
          initialChildren: children,
        );

  static const String name = 'CustomComplaintsInboxSearchRoute';

  static const PageInfo<CustomComplaintsInboxSearchRouteArgs> page =
      PageInfo<CustomComplaintsInboxSearchRouteArgs>(name);
}

class CustomComplaintsInboxSearchRouteArgs {
  const CustomComplaintsInboxSearchRouteArgs({
    this.key,
    this.appLocalizations,
  });

  final Key? key;

  final ComplaintsLocalization? appLocalizations;

  @override
  String toString() {
    return 'CustomComplaintsInboxSearchRouteArgs{key: $key, appLocalizations: $appLocalizations}';
  }
}

/// generated route for
/// [CustomDeliverInterventionPage]
class CustomDeliverInterventionRoute
    extends PageRouteInfo<CustomDeliverInterventionRouteArgs> {
  CustomDeliverInterventionRoute({
    Key? key,
    RegistrationDeliveryLocalization? appLocalizations,
    required EligibilityAssessmentType eligibilityAssessmentType,
    bool isEditing = false,
    List<PageRouteInfo>? children,
  }) : super(
          CustomDeliverInterventionRoute.name,
          args: CustomDeliverInterventionRouteArgs(
            key: key,
            appLocalizations: appLocalizations,
            eligibilityAssessmentType: eligibilityAssessmentType,
            isEditing: isEditing,
          ),
          initialChildren: children,
        );

  static const String name = 'CustomDeliverInterventionRoute';

  static const PageInfo<CustomDeliverInterventionRouteArgs> page =
      PageInfo<CustomDeliverInterventionRouteArgs>(name);
}

class CustomDeliverInterventionRouteArgs {
  const CustomDeliverInterventionRouteArgs({
    this.key,
    this.appLocalizations,
    required this.eligibilityAssessmentType,
    this.isEditing = false,
  });

  final Key? key;

  final RegistrationDeliveryLocalization? appLocalizations;

  final EligibilityAssessmentType eligibilityAssessmentType;

  final bool isEditing;

  @override
  String toString() {
    return 'CustomDeliverInterventionRouteArgs{key: $key, appLocalizations: $appLocalizations, eligibilityAssessmentType: $eligibilityAssessmentType, isEditing: $isEditing}';
  }
}

/// generated route for
/// [CustomDeliverySummaryPage]
class CustomDeliverySummaryRoute
    extends PageRouteInfo<CustomDeliverySummaryRouteArgs> {
  CustomDeliverySummaryRoute({
    Key? key,
    RegistrationDeliveryLocalization? appLocalizations,
    required EligibilityAssessmentType eligibilityAssessmentType,
    required TaskModel task,
    List<PageRouteInfo>? children,
  }) : super(
          CustomDeliverySummaryRoute.name,
          args: CustomDeliverySummaryRouteArgs(
            key: key,
            appLocalizations: appLocalizations,
            eligibilityAssessmentType: eligibilityAssessmentType,
            task: task,
          ),
          initialChildren: children,
        );

  static const String name = 'CustomDeliverySummaryRoute';

  static const PageInfo<CustomDeliverySummaryRouteArgs> page =
      PageInfo<CustomDeliverySummaryRouteArgs>(name);
}

class CustomDeliverySummaryRouteArgs {
  const CustomDeliverySummaryRouteArgs({
    this.key,
    this.appLocalizations,
    required this.eligibilityAssessmentType,
    required this.task,
  });

  final Key? key;

  final RegistrationDeliveryLocalization? appLocalizations;

  final EligibilityAssessmentType eligibilityAssessmentType;

  final TaskModel task;

  @override
  String toString() {
    return 'CustomDeliverySummaryRouteArgs{key: $key, appLocalizations: $appLocalizations, eligibilityAssessmentType: $eligibilityAssessmentType, task: $task}';
  }
}

/// generated route for
/// [CustomDoseAdministeredPage]
class CustomDoseAdministeredRoute
    extends PageRouteInfo<CustomDoseAdministeredRouteArgs> {
  CustomDoseAdministeredRoute({
    Key? key,
    RegistrationDeliveryLocalization? appLocalizations,
    required EligibilityAssessmentType eligibilityAssessmentType,
    List<PageRouteInfo>? children,
  }) : super(
          CustomDoseAdministeredRoute.name,
          args: CustomDoseAdministeredRouteArgs(
            key: key,
            appLocalizations: appLocalizations,
            eligibilityAssessmentType: eligibilityAssessmentType,
          ),
          initialChildren: children,
        );

  static const String name = 'CustomDoseAdministeredRoute';

  static const PageInfo<CustomDoseAdministeredRouteArgs> page =
      PageInfo<CustomDoseAdministeredRouteArgs>(name);
}

class CustomDoseAdministeredRouteArgs {
  const CustomDoseAdministeredRouteArgs({
    this.key,
    this.appLocalizations,
    required this.eligibilityAssessmentType,
  });

  final Key? key;

  final RegistrationDeliveryLocalization? appLocalizations;

  final EligibilityAssessmentType eligibilityAssessmentType;

  @override
  String toString() {
    return 'CustomDoseAdministeredRouteArgs{key: $key, appLocalizations: $appLocalizations, eligibilityAssessmentType: $eligibilityAssessmentType}';
  }
}

/// generated route for
/// [CustomFacilitySelectionSMCPage]
class CustomFacilitySelectionSMCRoute
    extends PageRouteInfo<CustomFacilitySelectionSMCRouteArgs> {
  CustomFacilitySelectionSMCRoute({
    Key? key,
    InventoryLocalization? appLocalizations,
    required List<FacilityModel> facilities,
    List<PageRouteInfo>? children,
  }) : super(
          CustomFacilitySelectionSMCRoute.name,
          args: CustomFacilitySelectionSMCRouteArgs(
            key: key,
            appLocalizations: appLocalizations,
            facilities: facilities,
          ),
          initialChildren: children,
        );

  static const String name = 'CustomFacilitySelectionSMCRoute';

  static const PageInfo<CustomFacilitySelectionSMCRouteArgs> page =
      PageInfo<CustomFacilitySelectionSMCRouteArgs>(name);
}

class CustomFacilitySelectionSMCRouteArgs {
  const CustomFacilitySelectionSMCRouteArgs({
    this.key,
    this.appLocalizations,
    required this.facilities,
  });

  final Key? key;

  final InventoryLocalization? appLocalizations;

  final List<FacilityModel> facilities;

  @override
  String toString() {
    return 'CustomFacilitySelectionSMCRouteArgs{key: $key, appLocalizations: $appLocalizations, facilities: $facilities}';
  }
}

/// generated route for
/// [CustomHFCreateReferralWrapperPage]
class CustomHFCreateReferralWrapperRoute
    extends PageRouteInfo<CustomHFCreateReferralWrapperRouteArgs> {
  CustomHFCreateReferralWrapperRoute({
    Key? key,
    required String projectId,
    bool viewOnly = false,
    HFReferralModel? referralReconciliation,
    required List<String> cycles,
    List<PageRouteInfo>? children,
  }) : super(
          CustomHFCreateReferralWrapperRoute.name,
          args: CustomHFCreateReferralWrapperRouteArgs(
            key: key,
            projectId: projectId,
            viewOnly: viewOnly,
            referralReconciliation: referralReconciliation,
            cycles: cycles,
          ),
          initialChildren: children,
        );

  static const String name = 'CustomHFCreateReferralWrapperRoute';

  static const PageInfo<CustomHFCreateReferralWrapperRouteArgs> page =
      PageInfo<CustomHFCreateReferralWrapperRouteArgs>(name);
}

class CustomHFCreateReferralWrapperRouteArgs {
  const CustomHFCreateReferralWrapperRouteArgs({
    this.key,
    required this.projectId,
    this.viewOnly = false,
    this.referralReconciliation,
    required this.cycles,
  });

  final Key? key;

  final String projectId;

  final bool viewOnly;

  final HFReferralModel? referralReconciliation;

  final List<String> cycles;

  @override
  String toString() {
    return 'CustomHFCreateReferralWrapperRouteArgs{key: $key, projectId: $projectId, viewOnly: $viewOnly, referralReconciliation: $referralReconciliation, cycles: $cycles}';
  }
}

/// generated route for
/// [CustomHouseHoldDetailsPage]
class CustomHouseHoldDetailsRoute
    extends PageRouteInfo<CustomHouseHoldDetailsRouteArgs> {
  CustomHouseHoldDetailsRoute({
    Key? key,
    RegistrationDeliveryLocalization? appLocalizations,
    List<PageRouteInfo>? children,
  }) : super(
          CustomHouseHoldDetailsRoute.name,
          args: CustomHouseHoldDetailsRouteArgs(
            key: key,
            appLocalizations: appLocalizations,
          ),
          initialChildren: children,
        );

  static const String name = 'CustomHouseHoldDetailsRoute';

  static const PageInfo<CustomHouseHoldDetailsRouteArgs> page =
      PageInfo<CustomHouseHoldDetailsRouteArgs>(name);
}

class CustomHouseHoldDetailsRouteArgs {
  const CustomHouseHoldDetailsRouteArgs({
    this.key,
    this.appLocalizations,
  });

  final Key? key;

  final RegistrationDeliveryLocalization? appLocalizations;

  @override
  String toString() {
    return 'CustomHouseHoldDetailsRouteArgs{key: $key, appLocalizations: $appLocalizations}';
  }
}

/// generated route for
/// [CustomHouseholdAcknowledgementPage]
class CustomHouseholdAcknowledgementRoute
    extends PageRouteInfo<CustomHouseholdAcknowledgementRouteArgs> {
  CustomHouseholdAcknowledgementRoute({
    Key? key,
    RegistrationDeliveryLocalization? appLocalizations,
    bool? enableViewHousehold,
    required EligibilityAssessmentType eligibilityAssessmentType,
    List<PageRouteInfo>? children,
  }) : super(
          CustomHouseholdAcknowledgementRoute.name,
          args: CustomHouseholdAcknowledgementRouteArgs(
            key: key,
            appLocalizations: appLocalizations,
            enableViewHousehold: enableViewHousehold,
            eligibilityAssessmentType: eligibilityAssessmentType,
          ),
          initialChildren: children,
        );

  static const String name = 'CustomHouseholdAcknowledgementRoute';

  static const PageInfo<CustomHouseholdAcknowledgementRouteArgs> page =
      PageInfo<CustomHouseholdAcknowledgementRouteArgs>(name);
}

class CustomHouseholdAcknowledgementRouteArgs {
  const CustomHouseholdAcknowledgementRouteArgs({
    this.key,
    this.appLocalizations,
    this.enableViewHousehold,
    required this.eligibilityAssessmentType,
  });

  final Key? key;

  final RegistrationDeliveryLocalization? appLocalizations;

  final bool? enableViewHousehold;

  final EligibilityAssessmentType eligibilityAssessmentType;

  @override
  String toString() {
    return 'CustomHouseholdAcknowledgementRouteArgs{key: $key, appLocalizations: $appLocalizations, enableViewHousehold: $enableViewHousehold, eligibilityAssessmentType: $eligibilityAssessmentType}';
  }
}

/// generated route for
/// [CustomHouseholdAcknowledgementSMCPage]
class CustomHouseholdAcknowledgementSMCRoute
    extends PageRouteInfo<CustomHouseholdAcknowledgementSMCRouteArgs> {
  CustomHouseholdAcknowledgementSMCRoute({
    Key? key,
    AppLocalizations? appLocalizations,
    bool? enableViewHousehold,
    bool? isReferral,
    List<PageRouteInfo>? children,
  }) : super(
          CustomHouseholdAcknowledgementSMCRoute.name,
          args: CustomHouseholdAcknowledgementSMCRouteArgs(
            key: key,
            appLocalizations: appLocalizations,
            enableViewHousehold: enableViewHousehold,
            isReferral: isReferral,
          ),
          initialChildren: children,
        );

  static const String name = 'CustomHouseholdAcknowledgementSMCRoute';

  static const PageInfo<CustomHouseholdAcknowledgementSMCRouteArgs> page =
      PageInfo<CustomHouseholdAcknowledgementSMCRouteArgs>(name);
}

class CustomHouseholdAcknowledgementSMCRouteArgs {
  const CustomHouseholdAcknowledgementSMCRouteArgs({
    this.key,
    this.appLocalizations,
    this.enableViewHousehold,
    this.isReferral,
  });

  final Key? key;

  final AppLocalizations? appLocalizations;

  final bool? enableViewHousehold;

  final bool? isReferral;

  @override
  String toString() {
    return 'CustomHouseholdAcknowledgementSMCRouteArgs{key: $key, appLocalizations: $appLocalizations, enableViewHousehold: $enableViewHousehold, isReferral: $isReferral}';
  }
}

/// generated route for
/// [CustomHouseholdLocationPage]
class CustomHouseholdLocationRoute
    extends PageRouteInfo<CustomHouseholdLocationRouteArgs> {
  CustomHouseholdLocationRoute({
    Key? key,
    RegistrationDeliveryLocalization? appLocalizations,
    List<PageRouteInfo>? children,
  }) : super(
          CustomHouseholdLocationRoute.name,
          args: CustomHouseholdLocationRouteArgs(
            key: key,
            appLocalizations: appLocalizations,
          ),
          initialChildren: children,
        );

  static const String name = 'CustomHouseholdLocationRoute';

  static const PageInfo<CustomHouseholdLocationRouteArgs> page =
      PageInfo<CustomHouseholdLocationRouteArgs>(name);
}

class CustomHouseholdLocationRouteArgs {
  const CustomHouseholdLocationRouteArgs({
    this.key,
    this.appLocalizations,
  });

  final Key? key;

  final RegistrationDeliveryLocalization? appLocalizations;

  @override
  String toString() {
    return 'CustomHouseholdLocationRouteArgs{key: $key, appLocalizations: $appLocalizations}';
  }
}

/// generated route for
/// [CustomHouseholdOverviewPage]
class CustomHouseholdOverviewRoute
    extends PageRouteInfo<CustomHouseholdOverviewRouteArgs> {
  CustomHouseholdOverviewRoute({
    Key? key,
    RegistrationDeliveryLocalization? appLocalizations,
    List<PageRouteInfo>? children,
  }) : super(
          CustomHouseholdOverviewRoute.name,
          args: CustomHouseholdOverviewRouteArgs(
            key: key,
            appLocalizations: appLocalizations,
          ),
          initialChildren: children,
        );

  static const String name = 'CustomHouseholdOverviewRoute';

  static const PageInfo<CustomHouseholdOverviewRouteArgs> page =
      PageInfo<CustomHouseholdOverviewRouteArgs>(name);
}

class CustomHouseholdOverviewRouteArgs {
  const CustomHouseholdOverviewRouteArgs({
    this.key,
    this.appLocalizations,
  });

  final Key? key;

  final RegistrationDeliveryLocalization? appLocalizations;

  @override
  String toString() {
    return 'CustomHouseholdOverviewRouteArgs{key: $key, appLocalizations: $appLocalizations}';
  }
}

/// generated route for
/// [CustomIndividualDetailsPage]
class CustomIndividualDetailsRoute
    extends PageRouteInfo<CustomIndividualDetailsRouteArgs> {
  CustomIndividualDetailsRoute({
    Key? key,
    RegistrationDeliveryLocalization? appLocalizations,
    bool isHeadOfHousehold = false,
    List<PageRouteInfo>? children,
  }) : super(
          CustomIndividualDetailsRoute.name,
          args: CustomIndividualDetailsRouteArgs(
            key: key,
            appLocalizations: appLocalizations,
            isHeadOfHousehold: isHeadOfHousehold,
          ),
          initialChildren: children,
        );

  static const String name = 'CustomIndividualDetailsRoute';

  static const PageInfo<CustomIndividualDetailsRouteArgs> page =
      PageInfo<CustomIndividualDetailsRouteArgs>(name);
}

class CustomIndividualDetailsRouteArgs {
  const CustomIndividualDetailsRouteArgs({
    this.key,
    this.appLocalizations,
    this.isHeadOfHousehold = false,
  });

  final Key? key;

  final RegistrationDeliveryLocalization? appLocalizations;

  final bool isHeadOfHousehold;

  @override
  String toString() {
    return 'CustomIndividualDetailsRouteArgs{key: $key, appLocalizations: $appLocalizations, isHeadOfHousehold: $isHeadOfHousehold}';
  }
}

/// generated route for
/// [CustomInventoryAcknowledgementPage]
class CustomInventoryAcknowledgementRoute
    extends PageRouteInfo<CustomInventoryAcknowledgementRouteArgs> {
  CustomInventoryAcknowledgementRoute({
    Key? key,
    InventoryLocalization? appLocalizations,
    bool isDataRecordSuccess = false,
    String? label,
    String? description,
    Map<String, dynamic>? descriptionTableData,
    List<PageRouteInfo>? children,
  }) : super(
          CustomInventoryAcknowledgementRoute.name,
          args: CustomInventoryAcknowledgementRouteArgs(
            key: key,
            appLocalizations: appLocalizations,
            isDataRecordSuccess: isDataRecordSuccess,
            label: label,
            description: description,
            descriptionTableData: descriptionTableData,
          ),
          initialChildren: children,
        );

  static const String name = 'CustomInventoryAcknowledgementRoute';

  static const PageInfo<CustomInventoryAcknowledgementRouteArgs> page =
      PageInfo<CustomInventoryAcknowledgementRouteArgs>(name);
}

class CustomInventoryAcknowledgementRouteArgs {
  const CustomInventoryAcknowledgementRouteArgs({
    this.key,
    this.appLocalizations,
    this.isDataRecordSuccess = false,
    this.label,
    this.description,
    this.descriptionTableData,
  });

  final Key? key;

  final InventoryLocalization? appLocalizations;

  final bool isDataRecordSuccess;

  final String? label;

  final String? description;

  final Map<String, dynamic>? descriptionTableData;

  @override
  String toString() {
    return 'CustomInventoryAcknowledgementRouteArgs{key: $key, appLocalizations: $appLocalizations, isDataRecordSuccess: $isDataRecordSuccess, label: $label, description: $description, descriptionTableData: $descriptionTableData}';
  }
}

/// generated route for
/// [CustomInventoryFacilitySelectionPage]
class CustomInventoryFacilitySelectionRoute
    extends PageRouteInfo<CustomInventoryFacilitySelectionRouteArgs> {
  CustomInventoryFacilitySelectionRoute({
    Key? key,
    InventoryLocalization? appLocalizations,
    required List<FacilityModel> facilities,
    List<PageRouteInfo>? children,
  }) : super(
          CustomInventoryFacilitySelectionRoute.name,
          args: CustomInventoryFacilitySelectionRouteArgs(
            key: key,
            appLocalizations: appLocalizations,
            facilities: facilities,
          ),
          initialChildren: children,
        );

  static const String name = 'CustomInventoryFacilitySelectionRoute';

  static const PageInfo<CustomInventoryFacilitySelectionRouteArgs> page =
      PageInfo<CustomInventoryFacilitySelectionRouteArgs>(name);
}

class CustomInventoryFacilitySelectionRouteArgs {
  const CustomInventoryFacilitySelectionRouteArgs({
    this.key,
    this.appLocalizations,
    required this.facilities,
  });

  final Key? key;

  final InventoryLocalization? appLocalizations;

  final List<FacilityModel> facilities;

  @override
  String toString() {
    return 'CustomInventoryFacilitySelectionRouteArgs{key: $key, appLocalizations: $appLocalizations, facilities: $facilities}';
  }
}

/// generated route for
/// [CustomInventoryFacilitySelectionSMCPage]
class CustomInventoryFacilitySelectionSMCRoute
    extends PageRouteInfo<CustomInventoryFacilitySelectionSMCRouteArgs> {
  CustomInventoryFacilitySelectionSMCRoute({
    Key? key,
    InventoryLocalization? appLocalizations,
    required List<FacilityModel> facilities,
    List<PageRouteInfo>? children,
  }) : super(
          CustomInventoryFacilitySelectionSMCRoute.name,
          args: CustomInventoryFacilitySelectionSMCRouteArgs(
            key: key,
            appLocalizations: appLocalizations,
            facilities: facilities,
          ),
          initialChildren: children,
        );

  static const String name = 'CustomInventoryFacilitySelectionSMCRoute';

  static const PageInfo<CustomInventoryFacilitySelectionSMCRouteArgs> page =
      PageInfo<CustomInventoryFacilitySelectionSMCRouteArgs>(name);
}

class CustomInventoryFacilitySelectionSMCRouteArgs {
  const CustomInventoryFacilitySelectionSMCRouteArgs({
    this.key,
    this.appLocalizations,
    required this.facilities,
  });

  final Key? key;

  final InventoryLocalization? appLocalizations;

  final List<FacilityModel> facilities;

  @override
  String toString() {
    return 'CustomInventoryFacilitySelectionSMCRouteArgs{key: $key, appLocalizations: $appLocalizations, facilities: $facilities}';
  }
}

/// generated route for
/// [CustomInventoryReportDetailsPage]
class CustomInventoryReportDetailsRoute
    extends PageRouteInfo<CustomInventoryReportDetailsRouteArgs> {
  CustomInventoryReportDetailsRoute({
    Key? key,
    InventoryLocalization? appLocalizations,
    required InventoryReportType reportType,
    List<PageRouteInfo>? children,
  }) : super(
          CustomInventoryReportDetailsRoute.name,
          args: CustomInventoryReportDetailsRouteArgs(
            key: key,
            appLocalizations: appLocalizations,
            reportType: reportType,
          ),
          initialChildren: children,
        );

  static const String name = 'CustomInventoryReportDetailsRoute';

  static const PageInfo<CustomInventoryReportDetailsRouteArgs> page =
      PageInfo<CustomInventoryReportDetailsRouteArgs>(name);
}

class CustomInventoryReportDetailsRouteArgs {
  const CustomInventoryReportDetailsRouteArgs({
    this.key,
    this.appLocalizations,
    required this.reportType,
  });

  final Key? key;

  final InventoryLocalization? appLocalizations;

  final InventoryReportType reportType;

  @override
  String toString() {
    return 'CustomInventoryReportDetailsRouteArgs{key: $key, appLocalizations: $appLocalizations, reportType: $reportType}';
  }
}

/// generated route for
/// [CustomInventoryReportSelectionPage]
class CustomInventoryReportSelectionRoute
    extends PageRouteInfo<CustomInventoryReportSelectionRouteArgs> {
  CustomInventoryReportSelectionRoute({
    Key? key,
    InventoryLocalization? appLocalizations,
    List<PageRouteInfo>? children,
  }) : super(
          CustomInventoryReportSelectionRoute.name,
          args: CustomInventoryReportSelectionRouteArgs(
            key: key,
            appLocalizations: appLocalizations,
          ),
          initialChildren: children,
        );

  static const String name = 'CustomInventoryReportSelectionRoute';

  static const PageInfo<CustomInventoryReportSelectionRouteArgs> page =
      PageInfo<CustomInventoryReportSelectionRouteArgs>(name);
}

class CustomInventoryReportSelectionRouteArgs {
  const CustomInventoryReportSelectionRouteArgs({
    this.key,
    this.appLocalizations,
  });

  final Key? key;

  final InventoryLocalization? appLocalizations;

  @override
  String toString() {
    return 'CustomInventoryReportSelectionRouteArgs{key: $key, appLocalizations: $appLocalizations}';
  }
}

/// generated route for
/// [CustomManageAttendancePage]
class CustomManageAttendanceRoute extends PageRouteInfo<void> {
  const CustomManageAttendanceRoute({List<PageRouteInfo>? children})
      : super(
          CustomManageAttendanceRoute.name,
          initialChildren: children,
        );

  static const String name = 'CustomManageAttendanceRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [CustomManageStocksPage]
class CustomManageStocksRoute
    extends PageRouteInfo<CustomManageStocksRouteArgs> {
  CustomManageStocksRoute({
    Key? key,
    InventoryLocalization? appLocalizations,
    List<PageRouteInfo>? children,
  }) : super(
          CustomManageStocksRoute.name,
          args: CustomManageStocksRouteArgs(
            key: key,
            appLocalizations: appLocalizations,
          ),
          initialChildren: children,
        );

  static const String name = 'CustomManageStocksRoute';

  static const PageInfo<CustomManageStocksRouteArgs> page =
      PageInfo<CustomManageStocksRouteArgs>(name);
}

class CustomManageStocksRouteArgs {
  const CustomManageStocksRouteArgs({
    this.key,
    this.appLocalizations,
  });

  final Key? key;

  final InventoryLocalization? appLocalizations;

  @override
  String toString() {
    return 'CustomManageStocksRouteArgs{key: $key, appLocalizations: $appLocalizations}';
  }
}

/// generated route for
/// [CustomMarkAttendancePage]
class CustomMarkAttendanceRoute
    extends PageRouteInfo<CustomMarkAttendanceRouteArgs> {
  CustomMarkAttendanceRoute({
    required List<AttendeeModel> attendees,
    required String registerId,
    required String tenantId,
    required DateTime dateTime,
    required int entryTime,
    required int exitTime,
    int? session,
    Key? key,
    AppLocalizations? appLocalizations,
    List<PageRouteInfo>? children,
  }) : super(
          CustomMarkAttendanceRoute.name,
          args: CustomMarkAttendanceRouteArgs(
            attendees: attendees,
            registerId: registerId,
            tenantId: tenantId,
            dateTime: dateTime,
            entryTime: entryTime,
            exitTime: exitTime,
            session: session,
            key: key,
            appLocalizations: appLocalizations,
          ),
          initialChildren: children,
        );

  static const String name = 'CustomMarkAttendanceRoute';

  static const PageInfo<CustomMarkAttendanceRouteArgs> page =
      PageInfo<CustomMarkAttendanceRouteArgs>(name);
}

class CustomMarkAttendanceRouteArgs {
  const CustomMarkAttendanceRouteArgs({
    required this.attendees,
    required this.registerId,
    required this.tenantId,
    required this.dateTime,
    required this.entryTime,
    required this.exitTime,
    this.session,
    this.key,
    this.appLocalizations,
  });

  final List<AttendeeModel> attendees;

  final String registerId;

  final String tenantId;

  final DateTime dateTime;

  final int entryTime;

  final int exitTime;

  final int? session;

  final Key? key;

  final AppLocalizations? appLocalizations;

  @override
  String toString() {
    return 'CustomMarkAttendanceRouteArgs{attendees: $attendees, registerId: $registerId, tenantId: $tenantId, dateTime: $dateTime, entryTime: $entryTime, exitTime: $exitTime, session: $session, key: $key, appLocalizations: $appLocalizations}';
  }
}

/// generated route for
/// [CustomRecordReferralDetailsPage]
class CustomRecordReferralDetailsRoute
    extends PageRouteInfo<CustomRecordReferralDetailsRouteArgs> {
  CustomRecordReferralDetailsRoute({
    Key? key,
    ReferralReconLocalization? appLocalizations,
    bool isEditing = false,
    required String projectId,
    required List<String> cycles,
    List<PageRouteInfo>? children,
  }) : super(
          CustomRecordReferralDetailsRoute.name,
          args: CustomRecordReferralDetailsRouteArgs(
            key: key,
            appLocalizations: appLocalizations,
            isEditing: isEditing,
            projectId: projectId,
            cycles: cycles,
          ),
          initialChildren: children,
        );

  static const String name = 'CustomRecordReferralDetailsRoute';

  static const PageInfo<CustomRecordReferralDetailsRouteArgs> page =
      PageInfo<CustomRecordReferralDetailsRouteArgs>(name);
}

class CustomRecordReferralDetailsRouteArgs {
  const CustomRecordReferralDetailsRouteArgs({
    this.key,
    this.appLocalizations,
    this.isEditing = false,
    required this.projectId,
    required this.cycles,
  });

  final Key? key;

  final ReferralReconLocalization? appLocalizations;

  final bool isEditing;

  final String projectId;

  final List<String> cycles;

  @override
  String toString() {
    return 'CustomRecordReferralDetailsRouteArgs{key: $key, appLocalizations: $appLocalizations, isEditing: $isEditing, projectId: $projectId, cycles: $cycles}';
  }
}

/// generated route for
/// [CustomRecordStockWrapperPage]
class CustomRecordStockWrapperRoute
    extends PageRouteInfo<CustomRecordStockWrapperRouteArgs> {
  CustomRecordStockWrapperRoute({
    Key? key,
    required StockRecordEntryType type,
    List<PageRouteInfo>? children,
  }) : super(
          CustomRecordStockWrapperRoute.name,
          args: CustomRecordStockWrapperRouteArgs(
            key: key,
            type: type,
          ),
          initialChildren: children,
        );

  static const String name = 'CustomRecordStockWrapperRoute';

  static const PageInfo<CustomRecordStockWrapperRouteArgs> page =
      PageInfo<CustomRecordStockWrapperRouteArgs>(name);
}

class CustomRecordStockWrapperRouteArgs {
  const CustomRecordStockWrapperRouteArgs({
    this.key,
    required this.type,
  });

  final Key? key;

  final StockRecordEntryType type;

  @override
  String toString() {
    return 'CustomRecordStockWrapperRouteArgs{key: $key, type: $type}';
  }
}

/// generated route for
/// [CustomReferBeneficiarySMCPage]
class CustomReferBeneficiarySMCRoute
    extends PageRouteInfo<CustomReferBeneficiarySMCRouteArgs> {
  CustomReferBeneficiarySMCRoute({
    Key? key,
    AppLocalizations? appLocalizations,
    bool isEditing = false,
    required String projectBeneficiaryClientRefId,
    required IndividualModel individual,
    bool isReadministrationUnSuccessful = false,
    String quantityWasted = "00",
    String? productVariantId,
    List<String>? referralReasons,
    List<PageRouteInfo>? children,
  }) : super(
          CustomReferBeneficiarySMCRoute.name,
          args: CustomReferBeneficiarySMCRouteArgs(
            key: key,
            appLocalizations: appLocalizations,
            isEditing: isEditing,
            projectBeneficiaryClientRefId: projectBeneficiaryClientRefId,
            individual: individual,
            isReadministrationUnSuccessful: isReadministrationUnSuccessful,
            quantityWasted: quantityWasted,
            productVariantId: productVariantId,
            referralReasons: referralReasons,
          ),
          initialChildren: children,
        );

  static const String name = 'CustomReferBeneficiarySMCRoute';

  static const PageInfo<CustomReferBeneficiarySMCRouteArgs> page =
      PageInfo<CustomReferBeneficiarySMCRouteArgs>(name);
}

class CustomReferBeneficiarySMCRouteArgs {
  const CustomReferBeneficiarySMCRouteArgs({
    this.key,
    this.appLocalizations,
    this.isEditing = false,
    required this.projectBeneficiaryClientRefId,
    required this.individual,
    this.isReadministrationUnSuccessful = false,
    this.quantityWasted = "00",
    this.productVariantId,
    this.referralReasons,
  });

  final Key? key;

  final AppLocalizations? appLocalizations;

  final bool isEditing;

  final String projectBeneficiaryClientRefId;

  final IndividualModel individual;

  final bool isReadministrationUnSuccessful;

  final String quantityWasted;

  final String? productVariantId;

  final List<String>? referralReasons;

  @override
  String toString() {
    return 'CustomReferBeneficiarySMCRouteArgs{key: $key, appLocalizations: $appLocalizations, isEditing: $isEditing, projectBeneficiaryClientRefId: $projectBeneficiaryClientRefId, individual: $individual, isReadministrationUnSuccessful: $isReadministrationUnSuccessful, quantityWasted: $quantityWasted, productVariantId: $productVariantId, referralReasons: $referralReasons}';
  }
}

/// generated route for
/// [CustomReferralFacilityPage]
class CustomReferralFacilityRoute
    extends PageRouteInfo<CustomReferralFacilityRouteArgs> {
  CustomReferralFacilityRoute({
    Key? key,
    ReferralReconLocalization? appLocalizations,
    bool isEditing = false,
    List<PageRouteInfo>? children,
  }) : super(
          CustomReferralFacilityRoute.name,
          args: CustomReferralFacilityRouteArgs(
            key: key,
            appLocalizations: appLocalizations,
            isEditing: isEditing,
          ),
          initialChildren: children,
        );

  static const String name = 'CustomReferralFacilityRoute';

  static const PageInfo<CustomReferralFacilityRouteArgs> page =
      PageInfo<CustomReferralFacilityRouteArgs>(name);
}

class CustomReferralFacilityRouteArgs {
  const CustomReferralFacilityRouteArgs({
    this.key,
    this.appLocalizations,
    this.isEditing = false,
  });

  final Key? key;

  final ReferralReconLocalization? appLocalizations;

  final bool isEditing;

  @override
  String toString() {
    return 'CustomReferralFacilityRouteArgs{key: $key, appLocalizations: $appLocalizations, isEditing: $isEditing}';
  }
}

/// generated route for
/// [CustomReferralReasonChecklistPage]
class CustomReferralReasonChecklistRoute
    extends PageRouteInfo<CustomReferralReasonChecklistRouteArgs> {
  CustomReferralReasonChecklistRoute({
    Key? key,
    String? referralClientRefId,
    ReferralReconLocalization? appLocalizations,
    List<PageRouteInfo>? children,
  }) : super(
          CustomReferralReasonChecklistRoute.name,
          args: CustomReferralReasonChecklistRouteArgs(
            key: key,
            referralClientRefId: referralClientRefId,
            appLocalizations: appLocalizations,
          ),
          initialChildren: children,
        );

  static const String name = 'CustomReferralReasonChecklistRoute';

  static const PageInfo<CustomReferralReasonChecklistRouteArgs> page =
      PageInfo<CustomReferralReasonChecklistRouteArgs>(name);
}

class CustomReferralReasonChecklistRouteArgs {
  const CustomReferralReasonChecklistRouteArgs({
    this.key,
    this.referralClientRefId,
    this.appLocalizations,
  });

  final Key? key;

  final String? referralClientRefId;

  final ReferralReconLocalization? appLocalizations;

  @override
  String toString() {
    return 'CustomReferralReasonChecklistRouteArgs{key: $key, referralClientRefId: $referralClientRefId, appLocalizations: $appLocalizations}';
  }
}

/// generated route for
/// [CustomReferralReasonChecklistPreviewPage]
class CustomReferralReasonChecklistPreviewRoute
    extends PageRouteInfo<CustomReferralReasonChecklistPreviewRouteArgs> {
  CustomReferralReasonChecklistPreviewRoute({
    Key? key,
    ReferralReconLocalization? appLocalizations,
    List<PageRouteInfo>? children,
  }) : super(
          CustomReferralReasonChecklistPreviewRoute.name,
          args: CustomReferralReasonChecklistPreviewRouteArgs(
            key: key,
            appLocalizations: appLocalizations,
          ),
          initialChildren: children,
        );

  static const String name = 'CustomReferralReasonChecklistPreviewRoute';

  static const PageInfo<CustomReferralReasonChecklistPreviewRouteArgs> page =
      PageInfo<CustomReferralReasonChecklistPreviewRouteArgs>(name);
}

class CustomReferralReasonChecklistPreviewRouteArgs {
  const CustomReferralReasonChecklistPreviewRouteArgs({
    this.key,
    this.appLocalizations,
  });

  final Key? key;

  final ReferralReconLocalization? appLocalizations;

  @override
  String toString() {
    return 'CustomReferralReasonChecklistPreviewRouteArgs{key: $key, appLocalizations: $appLocalizations}';
  }
}

/// generated route for
/// [CustomReferralReconProjectFacilitySelectionPage]
class CustomReferralReconProjectFacilitySelectionRoute extends PageRouteInfo<
    CustomReferralReconProjectFacilitySelectionRouteArgs> {
  CustomReferralReconProjectFacilitySelectionRoute({
    Key? key,
    ReferralReconLocalization? appLocalizations,
    required List<ProjectFacilityModel> projectFacilities,
    List<PageRouteInfo>? children,
  }) : super(
          CustomReferralReconProjectFacilitySelectionRoute.name,
          args: CustomReferralReconProjectFacilitySelectionRouteArgs(
            key: key,
            appLocalizations: appLocalizations,
            projectFacilities: projectFacilities,
          ),
          initialChildren: children,
        );

  static const String name = 'CustomReferralReconProjectFacilitySelectionRoute';

  static const PageInfo<CustomReferralReconProjectFacilitySelectionRouteArgs>
      page =
      PageInfo<CustomReferralReconProjectFacilitySelectionRouteArgs>(name);
}

class CustomReferralReconProjectFacilitySelectionRouteArgs {
  const CustomReferralReconProjectFacilitySelectionRouteArgs({
    this.key,
    this.appLocalizations,
    required this.projectFacilities,
  });

  final Key? key;

  final ReferralReconLocalization? appLocalizations;

  final List<ProjectFacilityModel> projectFacilities;

  @override
  String toString() {
    return 'CustomReferralReconProjectFacilitySelectionRouteArgs{key: $key, appLocalizations: $appLocalizations, projectFacilities: $projectFacilities}';
  }
}

/// generated route for
/// [CustomRegistrationDeliveryWrapperPage]
class CustomRegistrationDeliveryWrapperRoute extends PageRouteInfo<void> {
  const CustomRegistrationDeliveryWrapperRoute({List<PageRouteInfo>? children})
      : super(
          CustomRegistrationDeliveryWrapperRoute.name,
          initialChildren: children,
        );

  static const String name = 'CustomRegistrationDeliveryWrapperRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [CustomSearchBeneficiaryPage]
class CustomSearchBeneficiaryRoute
    extends PageRouteInfo<CustomSearchBeneficiaryRouteArgs> {
  CustomSearchBeneficiaryRoute({
    Key? key,
    RegistrationDeliveryLocalization? appLocalizations,
    List<PageRouteInfo>? children,
  }) : super(
          CustomSearchBeneficiaryRoute.name,
          args: CustomSearchBeneficiaryRouteArgs(
            key: key,
            appLocalizations: appLocalizations,
          ),
          initialChildren: children,
        );

  static const String name = 'CustomSearchBeneficiaryRoute';

  static const PageInfo<CustomSearchBeneficiaryRouteArgs> page =
      PageInfo<CustomSearchBeneficiaryRouteArgs>(name);
}

class CustomSearchBeneficiaryRouteArgs {
  const CustomSearchBeneficiaryRouteArgs({
    this.key,
    this.appLocalizations,
  });

  final Key? key;

  final RegistrationDeliveryLocalization? appLocalizations;

  @override
  String toString() {
    return 'CustomSearchBeneficiaryRouteArgs{key: $key, appLocalizations: $appLocalizations}';
  }
}

/// generated route for
/// [CustomSearchReferralReconciliationsPage]
class CustomSearchReferralReconciliationsRoute
    extends PageRouteInfo<CustomSearchReferralReconciliationsRouteArgs> {
  CustomSearchReferralReconciliationsRoute({
    Key? key,
    ReferralReconLocalization? appLocalizations,
    List<PageRouteInfo>? children,
  }) : super(
          CustomSearchReferralReconciliationsRoute.name,
          args: CustomSearchReferralReconciliationsRouteArgs(
            key: key,
            appLocalizations: appLocalizations,
          ),
          initialChildren: children,
        );

  static const String name = 'CustomSearchReferralReconciliationsRoute';

  static const PageInfo<CustomSearchReferralReconciliationsRouteArgs> page =
      PageInfo<CustomSearchReferralReconciliationsRouteArgs>(name);
}

class CustomSearchReferralReconciliationsRouteArgs {
  const CustomSearchReferralReconciliationsRouteArgs({
    this.key,
    this.appLocalizations,
  });

  final Key? key;

  final ReferralReconLocalization? appLocalizations;

  @override
  String toString() {
    return 'CustomSearchReferralReconciliationsRouteArgs{key: $key, appLocalizations: $appLocalizations}';
  }
}

/// generated route for
/// [CustomSideEffectsPage]
class CustomSideEffectsRoute extends PageRouteInfo<CustomSideEffectsRouteArgs> {
  CustomSideEffectsRoute({
    Key? key,
    RegistrationDeliveryLocalization? appLocalizations,
    required List<TaskModel> tasks,
    bool isEditing = false,
    List<PageRouteInfo>? children,
  }) : super(
          CustomSideEffectsRoute.name,
          args: CustomSideEffectsRouteArgs(
            key: key,
            appLocalizations: appLocalizations,
            tasks: tasks,
            isEditing: isEditing,
          ),
          initialChildren: children,
        );

  static const String name = 'CustomSideEffectsRoute';

  static const PageInfo<CustomSideEffectsRouteArgs> page =
      PageInfo<CustomSideEffectsRouteArgs>(name);
}

class CustomSideEffectsRouteArgs {
  const CustomSideEffectsRouteArgs({
    this.key,
    this.appLocalizations,
    required this.tasks,
    this.isEditing = false,
  });

  final Key? key;

  final RegistrationDeliveryLocalization? appLocalizations;

  final List<TaskModel> tasks;

  final bool isEditing;

  @override
  String toString() {
    return 'CustomSideEffectsRouteArgs{key: $key, appLocalizations: $appLocalizations, tasks: $tasks, isEditing: $isEditing}';
  }
}

/// generated route for
/// [CustomSplashAcknowledgementPage]
class CustomSplashAcknowledgementRoute
    extends PageRouteInfo<CustomSplashAcknowledgementRouteArgs> {
  CustomSplashAcknowledgementRoute({
    Key? key,
    RegistrationDeliveryLocalization? appLocalizations,
    bool? enableBackToSearch,
    required EligibilityAssessmentType eligibilityAssessmentType,
    bool? enableRouteToZeroDose = false,
    TaskModel? task,
    List<PageRouteInfo>? children,
  }) : super(
          CustomSplashAcknowledgementRoute.name,
          args: CustomSplashAcknowledgementRouteArgs(
            key: key,
            appLocalizations: appLocalizations,
            enableBackToSearch: enableBackToSearch,
            eligibilityAssessmentType: eligibilityAssessmentType,
            enableRouteToZeroDose: enableRouteToZeroDose,
            task: task,
          ),
          initialChildren: children,
        );

  static const String name = 'CustomSplashAcknowledgementRoute';

  static const PageInfo<CustomSplashAcknowledgementRouteArgs> page =
      PageInfo<CustomSplashAcknowledgementRouteArgs>(name);
}

class CustomSplashAcknowledgementRouteArgs {
  const CustomSplashAcknowledgementRouteArgs({
    this.key,
    this.appLocalizations,
    this.enableBackToSearch,
    required this.eligibilityAssessmentType,
    this.enableRouteToZeroDose = false,
    this.task,
  });

  final Key? key;

  final RegistrationDeliveryLocalization? appLocalizations;

  final bool? enableBackToSearch;

  final EligibilityAssessmentType eligibilityAssessmentType;

  final bool? enableRouteToZeroDose;

  final TaskModel? task;

  @override
  String toString() {
    return 'CustomSplashAcknowledgementRouteArgs{key: $key, appLocalizations: $appLocalizations, enableBackToSearch: $enableBackToSearch, eligibilityAssessmentType: $eligibilityAssessmentType, enableRouteToZeroDose: $enableRouteToZeroDose, task: $task}';
  }
}

/// generated route for
/// [CustomStockDetailsPage]
class CustomStockDetailsRoute
    extends PageRouteInfo<CustomStockDetailsRouteArgs> {
  CustomStockDetailsRoute({
    Key? key,
    InventoryLocalization? appLocalizations,
    List<PageRouteInfo>? children,
  }) : super(
          CustomStockDetailsRoute.name,
          args: CustomStockDetailsRouteArgs(
            key: key,
            appLocalizations: appLocalizations,
          ),
          initialChildren: children,
        );

  static const String name = 'CustomStockDetailsRoute';

  static const PageInfo<CustomStockDetailsRouteArgs> page =
      PageInfo<CustomStockDetailsRouteArgs>(name);
}

class CustomStockDetailsRouteArgs {
  const CustomStockDetailsRouteArgs({
    this.key,
    this.appLocalizations,
  });

  final Key? key;

  final InventoryLocalization? appLocalizations;

  @override
  String toString() {
    return 'CustomStockDetailsRouteArgs{key: $key, appLocalizations: $appLocalizations}';
  }
}

/// generated route for
/// [CustomStockReconciliationPage]
class CustomStockReconciliationRoute
    extends PageRouteInfo<CustomStockReconciliationRouteArgs> {
  CustomStockReconciliationRoute({
    Key? key,
    InventoryLocalization? appLocalizations,
    List<PageRouteInfo>? children,
  }) : super(
          CustomStockReconciliationRoute.name,
          args: CustomStockReconciliationRouteArgs(
            key: key,
            appLocalizations: appLocalizations,
          ),
          initialChildren: children,
        );

  static const String name = 'CustomStockReconciliationRoute';

  static const PageInfo<CustomStockReconciliationRouteArgs> page =
      PageInfo<CustomStockReconciliationRouteArgs>(name);
}

class CustomStockReconciliationRouteArgs {
  const CustomStockReconciliationRouteArgs({
    this.key,
    this.appLocalizations,
  });

  final Key? key;

  final InventoryLocalization? appLocalizations;

  @override
  String toString() {
    return 'CustomStockReconciliationRouteArgs{key: $key, appLocalizations: $appLocalizations}';
  }
}

/// generated route for
/// [CustomSummaryPage]
class CustomSummaryRoute extends PageRouteInfo<CustomSummaryRouteArgs> {
  CustomSummaryRoute({
    Key? key,
    RegistrationDeliveryLocalization? appLocalizations,
    required dynamic name,
    List<PageRouteInfo>? children,
  }) : super(
          CustomSummaryRoute.name,
          args: CustomSummaryRouteArgs(
            key: key,
            appLocalizations: appLocalizations,
            name: name,
          ),
          initialChildren: children,
        );

  static const String name = 'CustomSummaryRoute';

  static const PageInfo<CustomSummaryRouteArgs> page =
      PageInfo<CustomSummaryRouteArgs>(name);
}

class CustomSummaryRouteArgs {
  const CustomSummaryRouteArgs({
    this.key,
    this.appLocalizations,
    required this.name,
  });

  final Key? key;

  final RegistrationDeliveryLocalization? appLocalizations;

  final dynamic name;

  @override
  String toString() {
    return 'CustomSummaryRouteArgs{key: $key, appLocalizations: $appLocalizations, name: $name}';
  }
}

/// generated route for
/// [CustomSummaryReportPage]
class CustomSummaryReportRoute
    extends PageRouteInfo<CustomSummaryReportRouteArgs> {
  CustomSummaryReportRoute({
    Key? key,
    AppLocalizations? appLocalizations,
    List<PageRouteInfo>? children,
  }) : super(
          CustomSummaryReportRoute.name,
          args: CustomSummaryReportRouteArgs(
            key: key,
            appLocalizations: appLocalizations,
          ),
          initialChildren: children,
        );

  static const String name = 'CustomSummaryReportRoute';

  static const PageInfo<CustomSummaryReportRouteArgs> page =
      PageInfo<CustomSummaryReportRouteArgs>(name);
}

class CustomSummaryReportRouteArgs {
  const CustomSummaryReportRouteArgs({
    this.key,
    this.appLocalizations,
  });

  final Key? key;

  final AppLocalizations? appLocalizations;

  @override
  String toString() {
    return 'CustomSummaryReportRouteArgs{key: $key, appLocalizations: $appLocalizations}';
  }
}

/// generated route for
/// [CustomSurveyFormAcknowledgementPage]
class CustomSurveyFormAcknowledgementRoute
    extends PageRouteInfo<CustomSurveyFormAcknowledgementRouteArgs> {
  CustomSurveyFormAcknowledgementRoute({
    Key? key,
    SurveyFormLocalization? appLocalizations,
    bool isDataRecordSuccess = false,
    String? label,
    String? description,
    Map<String, dynamic>? descriptionTableData,
    List<PageRouteInfo>? children,
  }) : super(
          CustomSurveyFormAcknowledgementRoute.name,
          args: CustomSurveyFormAcknowledgementRouteArgs(
            key: key,
            appLocalizations: appLocalizations,
            isDataRecordSuccess: isDataRecordSuccess,
            label: label,
            description: description,
            descriptionTableData: descriptionTableData,
          ),
          initialChildren: children,
        );

  static const String name = 'CustomSurveyFormAcknowledgementRoute';

  static const PageInfo<CustomSurveyFormAcknowledgementRouteArgs> page =
      PageInfo<CustomSurveyFormAcknowledgementRouteArgs>(name);
}

class CustomSurveyFormAcknowledgementRouteArgs {
  const CustomSurveyFormAcknowledgementRouteArgs({
    this.key,
    this.appLocalizations,
    this.isDataRecordSuccess = false,
    this.label,
    this.description,
    this.descriptionTableData,
  });

  final Key? key;

  final SurveyFormLocalization? appLocalizations;

  final bool isDataRecordSuccess;

  final String? label;

  final String? description;

  final Map<String, dynamic>? descriptionTableData;

  @override
  String toString() {
    return 'CustomSurveyFormAcknowledgementRouteArgs{key: $key, appLocalizations: $appLocalizations, isDataRecordSuccess: $isDataRecordSuccess, label: $label, description: $description, descriptionTableData: $descriptionTableData}';
  }
}

/// generated route for
/// [CustomSurveyFormBoundaryViewPage]
class CustomSurveyFormBoundaryViewRoute
    extends PageRouteInfo<CustomSurveyFormBoundaryViewRouteArgs> {
  CustomSurveyFormBoundaryViewRoute({
    Key? key,
    SurveyFormLocalization? appLocalizations,
    List<PageRouteInfo>? children,
  }) : super(
          CustomSurveyFormBoundaryViewRoute.name,
          args: CustomSurveyFormBoundaryViewRouteArgs(
            key: key,
            appLocalizations: appLocalizations,
          ),
          initialChildren: children,
        );

  static const String name = 'CustomSurveyFormBoundaryViewRoute';

  static const PageInfo<CustomSurveyFormBoundaryViewRouteArgs> page =
      PageInfo<CustomSurveyFormBoundaryViewRouteArgs>(name);
}

class CustomSurveyFormBoundaryViewRouteArgs {
  const CustomSurveyFormBoundaryViewRouteArgs({
    this.key,
    this.appLocalizations,
  });

  final Key? key;

  final SurveyFormLocalization? appLocalizations;

  @override
  String toString() {
    return 'CustomSurveyFormBoundaryViewRouteArgs{key: $key, appLocalizations: $appLocalizations}';
  }
}

/// generated route for
/// [CustomSurveyFormPreviewPage]
class CustomSurveyFormPreviewRoute
    extends PageRouteInfo<CustomSurveyFormPreviewRouteArgs> {
  CustomSurveyFormPreviewRoute({
    Key? key,
    SurveyFormLocalization? appLocalizations,
    List<PageRouteInfo>? children,
  }) : super(
          CustomSurveyFormPreviewRoute.name,
          args: CustomSurveyFormPreviewRouteArgs(
            key: key,
            appLocalizations: appLocalizations,
          ),
          initialChildren: children,
        );

  static const String name = 'CustomSurveyFormPreviewRoute';

  static const PageInfo<CustomSurveyFormPreviewRouteArgs> page =
      PageInfo<CustomSurveyFormPreviewRouteArgs>(name);
}

class CustomSurveyFormPreviewRouteArgs {
  const CustomSurveyFormPreviewRouteArgs({
    this.key,
    this.appLocalizations,
  });

  final Key? key;

  final SurveyFormLocalization? appLocalizations;

  @override
  String toString() {
    return 'CustomSurveyFormPreviewRouteArgs{key: $key, appLocalizations: $appLocalizations}';
  }
}

/// generated route for
/// [CustomSurveyFormViewPage]
class CustomSurveyFormViewRoute
    extends PageRouteInfo<CustomSurveyFormViewRouteArgs> {
  CustomSurveyFormViewRoute({
    Key? key,
    SurveyFormLocalization? appLocalizations,
    List<PageRouteInfo>? children,
  }) : super(
          CustomSurveyFormViewRoute.name,
          args: CustomSurveyFormViewRouteArgs(
            key: key,
            appLocalizations: appLocalizations,
          ),
          initialChildren: children,
        );

  static const String name = 'CustomSurveyFormViewRoute';

  static const PageInfo<CustomSurveyFormViewRouteArgs> page =
      PageInfo<CustomSurveyFormViewRouteArgs>(name);
}

class CustomSurveyFormViewRouteArgs {
  const CustomSurveyFormViewRouteArgs({
    this.key,
    this.appLocalizations,
  });

  final Key? key;

  final SurveyFormLocalization? appLocalizations;

  @override
  String toString() {
    return 'CustomSurveyFormViewRouteArgs{key: $key, appLocalizations: $appLocalizations}';
  }
}

/// generated route for
/// [CustomSurveyFormWrapperPage]
class CustomSurveyFormWrapperRoute
    extends PageRouteInfo<CustomSurveyFormWrapperRouteArgs> {
  CustomSurveyFormWrapperRoute({
    Key? key,
    bool isEditing = false,
    List<PageRouteInfo>? children,
  }) : super(
          CustomSurveyFormWrapperRoute.name,
          args: CustomSurveyFormWrapperRouteArgs(
            key: key,
            isEditing: isEditing,
          ),
          initialChildren: children,
        );

  static const String name = 'CustomSurveyFormWrapperRoute';

  static const PageInfo<CustomSurveyFormWrapperRouteArgs> page =
      PageInfo<CustomSurveyFormWrapperRouteArgs>(name);
}

class CustomSurveyFormWrapperRouteArgs {
  const CustomSurveyFormWrapperRouteArgs({
    this.key,
    this.isEditing = false,
  });

  final Key? key;

  final bool isEditing;

  @override
  String toString() {
    return 'CustomSurveyFormWrapperRouteArgs{key: $key, isEditing: $isEditing}';
  }
}

/// generated route for
/// [CustomSurveyformPage]
class CustomSurveyformRoute extends PageRouteInfo<CustomSurveyformRouteArgs> {
  CustomSurveyformRoute({
    Key? key,
    SurveyFormLocalization? appLocalizations,
    List<PageRouteInfo>? children,
  }) : super(
          CustomSurveyformRoute.name,
          args: CustomSurveyformRouteArgs(
            key: key,
            appLocalizations: appLocalizations,
          ),
          initialChildren: children,
        );

  static const String name = 'CustomSurveyformRoute';

  static const PageInfo<CustomSurveyformRouteArgs> page =
      PageInfo<CustomSurveyformRouteArgs>(name);
}

class CustomSurveyformRouteArgs {
  const CustomSurveyformRouteArgs({
    this.key,
    this.appLocalizations,
  });

  final Key? key;

  final SurveyFormLocalization? appLocalizations;

  @override
  String toString() {
    return 'CustomSurveyformRouteArgs{key: $key, appLocalizations: $appLocalizations}';
  }
}

/// generated route for
/// [CustomWarehouseDetailsPage]
class CustomWarehouseDetailsRoute
    extends PageRouteInfo<CustomWarehouseDetailsRouteArgs> {
  CustomWarehouseDetailsRoute({
    Key? key,
    InventoryLocalization? appLocalizations,
    List<PageRouteInfo>? children,
  }) : super(
          CustomWarehouseDetailsRoute.name,
          args: CustomWarehouseDetailsRouteArgs(
            key: key,
            appLocalizations: appLocalizations,
          ),
          initialChildren: children,
        );

  static const String name = 'CustomWarehouseDetailsRoute';

  static const PageInfo<CustomWarehouseDetailsRouteArgs> page =
      PageInfo<CustomWarehouseDetailsRouteArgs>(name);
}

class CustomWarehouseDetailsRouteArgs {
  const CustomWarehouseDetailsRouteArgs({
    this.key,
    this.appLocalizations,
  });

  final Key? key;

  final InventoryLocalization? appLocalizations;

  @override
  String toString() {
    return 'CustomWarehouseDetailsRouteArgs{key: $key, appLocalizations: $appLocalizations}';
  }
}

/// generated route for
/// [DigitScannerPage]
class DigitScannerRoute extends PageRouteInfo<DigitScannerRouteArgs> {
  DigitScannerRoute({
    Key? key,
    ScannerLocalization? appLocalizations,
    required int quantity,
    required bool isGS1code,
    bool singleValue = false,
    bool isEditEnabled = false,
    List<PageRouteInfo>? children,
  }) : super(
          DigitScannerRoute.name,
          args: DigitScannerRouteArgs(
            key: key,
            appLocalizations: appLocalizations,
            quantity: quantity,
            isGS1code: isGS1code,
            singleValue: singleValue,
            isEditEnabled: isEditEnabled,
          ),
          initialChildren: children,
        );

  static const String name = 'DigitScannerRoute';

  static const PageInfo<DigitScannerRouteArgs> page =
      PageInfo<DigitScannerRouteArgs>(name);
}

class DigitScannerRouteArgs {
  const DigitScannerRouteArgs({
    this.key,
    this.appLocalizations,
    required this.quantity,
    required this.isGS1code,
    this.singleValue = false,
    this.isEditEnabled = false,
  });

  final Key? key;

  final ScannerLocalization? appLocalizations;

  final int quantity;

  final bool isGS1code;

  final bool singleValue;

  final bool isEditEnabled;

  @override
  String toString() {
    return 'DigitScannerRouteArgs{key: $key, appLocalizations: $appLocalizations, quantity: $quantity, isGS1code: $isGS1code, singleValue: $singleValue, isEditEnabled: $isEditEnabled}';
  }
}

/// generated route for
/// [EligibilityChecklistViewPage]
class EligibilityChecklistViewRoute
    extends PageRouteInfo<EligibilityChecklistViewRouteArgs> {
  EligibilityChecklistViewRoute({
    Key? key,
    String? referralClientRefId,
    IndividualModel? individual,
    String? projectBeneficiaryClientReferenceId,
    required EligibilityAssessmentType eligibilityAssessmentType,
    AppLocalizations? appLocalizations,
    List<PageRouteInfo>? children,
  }) : super(
          EligibilityChecklistViewRoute.name,
          args: EligibilityChecklistViewRouteArgs(
            key: key,
            referralClientRefId: referralClientRefId,
            individual: individual,
            projectBeneficiaryClientReferenceId:
                projectBeneficiaryClientReferenceId,
            eligibilityAssessmentType: eligibilityAssessmentType,
            appLocalizations: appLocalizations,
          ),
          initialChildren: children,
        );

  static const String name = 'EligibilityChecklistViewRoute';

  static const PageInfo<EligibilityChecklistViewRouteArgs> page =
      PageInfo<EligibilityChecklistViewRouteArgs>(name);
}

class EligibilityChecklistViewRouteArgs {
  const EligibilityChecklistViewRouteArgs({
    this.key,
    this.referralClientRefId,
    this.individual,
    this.projectBeneficiaryClientReferenceId,
    required this.eligibilityAssessmentType,
    this.appLocalizations,
  });

  final Key? key;

  final String? referralClientRefId;

  final IndividualModel? individual;

  final String? projectBeneficiaryClientReferenceId;

  final EligibilityAssessmentType eligibilityAssessmentType;

  final AppLocalizations? appLocalizations;

  @override
  String toString() {
    return 'EligibilityChecklistViewRouteArgs{key: $key, referralClientRefId: $referralClientRefId, individual: $individual, projectBeneficiaryClientReferenceId: $projectBeneficiaryClientReferenceId, eligibilityAssessmentType: $eligibilityAssessmentType, appLocalizations: $appLocalizations}';
  }
}

/// generated route for
/// [HomePage]
class HomeRoute extends PageRouteInfo<HomeRouteArgs> {
  HomeRoute({
    Key? key,
    AppLocalizations? appLocalizations,
    List<PageRouteInfo>? children,
  }) : super(
          HomeRoute.name,
          args: HomeRouteArgs(
            key: key,
            appLocalizations: appLocalizations,
          ),
          initialChildren: children,
        );

  static const String name = 'HomeRoute';

  static const PageInfo<HomeRouteArgs> page = PageInfo<HomeRouteArgs>(name);
}

class HomeRouteArgs {
  const HomeRouteArgs({
    this.key,
    this.appLocalizations,
  });

  final Key? key;

  final AppLocalizations? appLocalizations;

  @override
  String toString() {
    return 'HomeRouteArgs{key: $key, appLocalizations: $appLocalizations}';
  }
}

/// generated route for
/// [LanguageSelectionPage]
class LanguageSelectionRoute extends PageRouteInfo<void> {
  const LanguageSelectionRoute({List<PageRouteInfo>? children})
      : super(
          LanguageSelectionRoute.name,
          initialChildren: children,
        );

  static const String name = 'LanguageSelectionRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [LoginPage]
class LoginRoute extends PageRouteInfo<LoginRouteArgs> {
  LoginRoute({
    Key? key,
    AppLocalizations? appLocalizations,
    List<PageRouteInfo>? children,
  }) : super(
          LoginRoute.name,
          args: LoginRouteArgs(
            key: key,
            appLocalizations: appLocalizations,
          ),
          initialChildren: children,
        );

  static const String name = 'LoginRoute';

  static const PageInfo<LoginRouteArgs> page = PageInfo<LoginRouteArgs>(name);
}

class LoginRouteArgs {
  const LoginRouteArgs({
    this.key,
    this.appLocalizations,
  });

  final Key? key;

  final AppLocalizations? appLocalizations;

  @override
  String toString() {
    return 'LoginRouteArgs{key: $key, appLocalizations: $appLocalizations}';
  }
}

/// generated route for
/// [ProfilePage]
class ProfileRoute extends PageRouteInfo<ProfileRouteArgs> {
  ProfileRoute({
    Key? key,
    AppLocalizations? appLocalizations,
    List<PageRouteInfo>? children,
  }) : super(
          ProfileRoute.name,
          args: ProfileRouteArgs(
            key: key,
            appLocalizations: appLocalizations,
          ),
          initialChildren: children,
        );

  static const String name = 'ProfileRoute';

  static const PageInfo<ProfileRouteArgs> page =
      PageInfo<ProfileRouteArgs>(name);
}

class ProfileRouteArgs {
  const ProfileRouteArgs({
    this.key,
    this.appLocalizations,
  });

  final Key? key;

  final AppLocalizations? appLocalizations;

  @override
  String toString() {
    return 'ProfileRouteArgs{key: $key, appLocalizations: $appLocalizations}';
  }
}

/// generated route for
/// [ProjectFacilitySelectionPage]
class ProjectFacilitySelectionRoute
    extends PageRouteInfo<ProjectFacilitySelectionRouteArgs> {
  ProjectFacilitySelectionRoute({
    Key? key,
    required List<ProjectFacilityModel> projectFacilities,
    List<PageRouteInfo>? children,
  }) : super(
          ProjectFacilitySelectionRoute.name,
          args: ProjectFacilitySelectionRouteArgs(
            key: key,
            projectFacilities: projectFacilities,
          ),
          initialChildren: children,
        );

  static const String name = 'ProjectFacilitySelectionRoute';

  static const PageInfo<ProjectFacilitySelectionRouteArgs> page =
      PageInfo<ProjectFacilitySelectionRouteArgs>(name);
}

class ProjectFacilitySelectionRouteArgs {
  const ProjectFacilitySelectionRouteArgs({
    this.key,
    required this.projectFacilities,
  });

  final Key? key;

  final List<ProjectFacilityModel> projectFacilities;

  @override
  String toString() {
    return 'ProjectFacilitySelectionRouteArgs{key: $key, projectFacilities: $projectFacilities}';
  }
}

/// generated route for
/// [ProjectSelectionPage]
class ProjectSelectionRoute extends PageRouteInfo<ProjectSelectionRouteArgs> {
  ProjectSelectionRoute({
    Key? key,
    AppLocalizations? appLocalizations,
    List<PageRouteInfo>? children,
  }) : super(
          ProjectSelectionRoute.name,
          args: ProjectSelectionRouteArgs(
            key: key,
            appLocalizations: appLocalizations,
          ),
          initialChildren: children,
        );

  static const String name = 'ProjectSelectionRoute';

  static const PageInfo<ProjectSelectionRouteArgs> page =
      PageInfo<ProjectSelectionRouteArgs>(name);
}

class ProjectSelectionRouteArgs {
  const ProjectSelectionRouteArgs({
    this.key,
    this.appLocalizations,
  });

  final Key? key;

  final AppLocalizations? appLocalizations;

  @override
  String toString() {
    return 'ProjectSelectionRouteArgs{key: $key, appLocalizations: $appLocalizations}';
  }
}

/// generated route for
/// [QRScannerPage]
class QRScannerRoute extends PageRouteInfo<QRScannerRouteArgs> {
  QRScannerRoute({
    Key? key,
    InventoryLocalization? appLocalizations,
    List<PageRouteInfo>? children,
  }) : super(
          QRScannerRoute.name,
          args: QRScannerRouteArgs(
            key: key,
            appLocalizations: appLocalizations,
          ),
          initialChildren: children,
        );

  static const String name = 'QRScannerRoute';

  static const PageInfo<QRScannerRouteArgs> page =
      PageInfo<QRScannerRouteArgs>(name);
}

class QRScannerRouteArgs {
  const QRScannerRouteArgs({
    this.key,
    this.appLocalizations,
  });

  final Key? key;

  final InventoryLocalization? appLocalizations;

  @override
  String toString() {
    return 'QRScannerRouteArgs{key: $key, appLocalizations: $appLocalizations}';
  }
}

/// generated route for
/// [RecordRedosePage]
class RecordRedoseRoute extends PageRouteInfo<RecordRedoseRouteArgs> {
  RecordRedoseRoute({
    Key? key,
    AppLocalizations? appLocalizations,
    bool isEditing = false,
    required List<TaskModel> tasks,
    List<PageRouteInfo>? children,
  }) : super(
          RecordRedoseRoute.name,
          args: RecordRedoseRouteArgs(
            key: key,
            appLocalizations: appLocalizations,
            isEditing: isEditing,
            tasks: tasks,
          ),
          initialChildren: children,
        );

  static const String name = 'RecordRedoseRoute';

  static const PageInfo<RecordRedoseRouteArgs> page =
      PageInfo<RecordRedoseRouteArgs>(name);
}

class RecordRedoseRouteArgs {
  const RecordRedoseRouteArgs({
    this.key,
    this.appLocalizations,
    this.isEditing = false,
    required this.tasks,
  });

  final Key? key;

  final AppLocalizations? appLocalizations;

  final bool isEditing;

  final List<TaskModel> tasks;

  @override
  String toString() {
    return 'RecordRedoseRouteArgs{key: $key, appLocalizations: $appLocalizations, isEditing: $isEditing, tasks: $tasks}';
  }
}

/// generated route for
/// [UnauthenticatedPageWrapper]
class UnauthenticatedRouteWrapper extends PageRouteInfo<void> {
  const UnauthenticatedRouteWrapper({List<PageRouteInfo>? children})
      : super(
          UnauthenticatedRouteWrapper.name,
          initialChildren: children,
        );

  static const String name = 'UnauthenticatedRouteWrapper';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [UserQRDetailsPage]
class UserQRDetailsRoute extends PageRouteInfo<UserQRDetailsRouteArgs> {
  UserQRDetailsRoute({
    Key? key,
    AppLocalizations? appLocalizations,
    List<PageRouteInfo>? children,
  }) : super(
          UserQRDetailsRoute.name,
          args: UserQRDetailsRouteArgs(
            key: key,
            appLocalizations: appLocalizations,
          ),
          initialChildren: children,
        );

  static const String name = 'UserQRDetailsRoute';

  static const PageInfo<UserQRDetailsRouteArgs> page =
      PageInfo<UserQRDetailsRouteArgs>(name);
}

class UserQRDetailsRouteArgs {
  const UserQRDetailsRouteArgs({
    this.key,
    this.appLocalizations,
  });

  final Key? key;

  final AppLocalizations? appLocalizations;

  @override
  String toString() {
    return 'UserQRDetailsRouteArgs{key: $key, appLocalizations: $appLocalizations}';
  }
}

/// generated route for
/// [VaccineSelectionPage]
class VaccineSelectionRoute extends PageRouteInfo<VaccineSelectionRouteArgs> {
  VaccineSelectionRoute({
    Key? key,
    AppLocalizations? appLocalizations,
    required bool isAdministration,
    required EligibilityAssessmentType eligibilityAssessmentType,
    required bool isChecklistAssessmentDone,
    String? projectBeneficiaryClientReferenceId,
    IndividualModel? individual,
    required TaskModel task,
    bool? hasSideEffects = false,
    required SideEffectModel sideEffect,
    bool isZeroDoseAlreadyDone = false,
    List<PageRouteInfo>? children,
  }) : super(
          VaccineSelectionRoute.name,
          args: VaccineSelectionRouteArgs(
            key: key,
            appLocalizations: appLocalizations,
            isAdministration: isAdministration,
            eligibilityAssessmentType: eligibilityAssessmentType,
            isChecklistAssessmentDone: isChecklistAssessmentDone,
            projectBeneficiaryClientReferenceId:
                projectBeneficiaryClientReferenceId,
            individual: individual,
            task: task,
            hasSideEffects: hasSideEffects,
            sideEffect: sideEffect,
            isZeroDoseAlreadyDone: isZeroDoseAlreadyDone,
          ),
          initialChildren: children,
        );

  static const String name = 'VaccineSelectionRoute';

  static const PageInfo<VaccineSelectionRouteArgs> page =
      PageInfo<VaccineSelectionRouteArgs>(name);
}

class VaccineSelectionRouteArgs {
  const VaccineSelectionRouteArgs({
    this.key,
    this.appLocalizations,
    required this.isAdministration,
    required this.eligibilityAssessmentType,
    required this.isChecklistAssessmentDone,
    this.projectBeneficiaryClientReferenceId,
    this.individual,
    required this.task,
    this.hasSideEffects = false,
    required this.sideEffect,
    this.isZeroDoseAlreadyDone = false,
  });

  final Key? key;

  final AppLocalizations? appLocalizations;

  final bool isAdministration;

  final EligibilityAssessmentType eligibilityAssessmentType;

  final bool isChecklistAssessmentDone;

  final String? projectBeneficiaryClientReferenceId;

  final IndividualModel? individual;

  final TaskModel task;

  final bool? hasSideEffects;

  final SideEffectModel sideEffect;

  final bool isZeroDoseAlreadyDone;

  @override
  String toString() {
    return 'VaccineSelectionRouteArgs{key: $key, appLocalizations: $appLocalizations, isAdministration: $isAdministration, eligibilityAssessmentType: $eligibilityAssessmentType, isChecklistAssessmentDone: $isChecklistAssessmentDone, projectBeneficiaryClientReferenceId: $projectBeneficiaryClientReferenceId, individual: $individual, task: $task, hasSideEffects: $hasSideEffects, sideEffect: $sideEffect, isZeroDoseAlreadyDone: $isZeroDoseAlreadyDone}';
  }
}

/// generated route for
/// [ZeroDoseCheckPage]
class ZeroDoseCheckRoute extends PageRouteInfo<ZeroDoseCheckRouteArgs> {
  ZeroDoseCheckRoute({
    Key? key,
    RegistrationDeliveryLocalization? appLocalizations,
    required EligibilityAssessmentType eligibilityAssessmentType,
    required bool isAdministration,
    bool isEditing = false,
    bool isChecklistAssessmentDone = true,
    String? projectBeneficiaryClientReferenceId,
    IndividualModel? individual,
    bool? hasSideEffects = false,
    bool isRefused = false,
    SideEffectModel? sideEffect,
    TaskModel? task,
    List<PageRouteInfo>? children,
  }) : super(
          ZeroDoseCheckRoute.name,
          args: ZeroDoseCheckRouteArgs(
            key: key,
            appLocalizations: appLocalizations,
            eligibilityAssessmentType: eligibilityAssessmentType,
            isAdministration: isAdministration,
            isEditing: isEditing,
            isChecklistAssessmentDone: isChecklistAssessmentDone,
            projectBeneficiaryClientReferenceId:
                projectBeneficiaryClientReferenceId,
            individual: individual,
            hasSideEffects: hasSideEffects,
            isRefused: isRefused,
            sideEffect: sideEffect,
            task: task,
          ),
          initialChildren: children,
        );

  static const String name = 'ZeroDoseCheckRoute';

  static const PageInfo<ZeroDoseCheckRouteArgs> page =
      PageInfo<ZeroDoseCheckRouteArgs>(name);
}

class ZeroDoseCheckRouteArgs {
  const ZeroDoseCheckRouteArgs({
    this.key,
    this.appLocalizations,
    required this.eligibilityAssessmentType,
    required this.isAdministration,
    this.isEditing = false,
    this.isChecklistAssessmentDone = true,
    this.projectBeneficiaryClientReferenceId,
    this.individual,
    this.hasSideEffects = false,
    this.isRefused = false,
    this.sideEffect,
    this.task,
  });

  final Key? key;

  final RegistrationDeliveryLocalization? appLocalizations;

  final EligibilityAssessmentType eligibilityAssessmentType;

  final bool isAdministration;

  final bool isEditing;

  final bool isChecklistAssessmentDone;

  final String? projectBeneficiaryClientReferenceId;

  final IndividualModel? individual;

  final bool? hasSideEffects;

  final bool isRefused;

  final SideEffectModel? sideEffect;

  final TaskModel? task;

  @override
  String toString() {
    return 'ZeroDoseCheckRouteArgs{key: $key, appLocalizations: $appLocalizations, eligibilityAssessmentType: $eligibilityAssessmentType, isAdministration: $isAdministration, isEditing: $isEditing, isChecklistAssessmentDone: $isChecklistAssessmentDone, projectBeneficiaryClientReferenceId: $projectBeneficiaryClientReferenceId, individual: $individual, hasSideEffects: $hasSideEffects, isRefused: $isRefused, sideEffect: $sideEffect, task: $task}';
  }
}
