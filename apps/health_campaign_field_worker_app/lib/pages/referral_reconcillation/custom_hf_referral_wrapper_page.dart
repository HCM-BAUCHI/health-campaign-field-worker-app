import 'package:auto_route/auto_route.dart';
import 'package:digit_data_model/data_model.dart';
import 'package:survey_form/survey_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:referral_reconciliation/blocs/app_localization.dart';
import 'package:referral_reconciliation/blocs/referral_recon_record.dart';
import 'package:referral_reconciliation/models/entities/hf_referral.dart';
import 'package:referral_reconciliation/utils/extensions/extensions.dart';

import 'package:referral_reconciliation/utils/i18_key_constants.dart' as i18;
import 'package:referral_reconciliation/blocs/referral_recon_service_definition.dart';
import 'package:referral_reconciliation/widgets/localized.dart';
import 'package:referral_reconciliation/widgets/project_facility_bloc_wrapper.dart';

@RoutePage()
class CustomHFCreateReferralWrapperPage extends LocalizedStatefulWidget {
  final bool viewOnly;
  final HFReferralModel? referralReconciliation;
  final List<String> cycles;
  final String projectId;

  const CustomHFCreateReferralWrapperPage({
    super.key,
    required this.projectId,
    this.viewOnly = false,
    this.referralReconciliation,
    required this.cycles,
  });

  @override
  State<CustomHFCreateReferralWrapperPage> createState() =>
      _HFCreateReferralWrapperPageState();
}

class _HFCreateReferralWrapperPageState
    extends State<CustomHFCreateReferralWrapperPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cycles.isEmpty) {
      return Center(
        child: Text(ReferralReconLocalization.of(context)
            .translate(i18.referralReconciliation.noCyclesFound)),
      );
    } else {
      return ProjectFacilityBlocWrapper(
          projectId: widget.projectId,
          child: BlocProvider(
            create: (_) => FacilityBloc(
                facilityDataRepository: context
                    .repository<FacilityModel, FacilitySearchModel>(context),
                projectFacilityDataRepository: context.repository<
                    ProjectFacilityModel, ProjectFacilitySearchModel>(context))
              ..add(FacilityLoadForProjectEvent(projectId: widget.projectId)),
            child: BlocProvider(
              create: (_) => ReferralReconServiceDefinitionBloc(
                const ReferralReconServiceDefinitionEmptyState(),
                serviceDefinitionDataRepository: context.repository<
                    ServiceDefinitionModel,
                    ServiceDefinitionSearchModel>(context),
              )..add(const ReferralReconServiceDefinitionFetchEvent()),
              child: BlocProvider(
                create: (_) => ServiceBloc(
                  const ServiceEmptyState(),
                  serviceDataRepository: context
                      .repository<ServiceModel, ServiceSearchModel>(context),
                )..add(ServiceSearchEvent(
                      serviceSearchModel: ServiceSearchModel(
                    relatedClientReferenceId:
                        widget.referralReconciliation?.clientReferenceId,
                  ))),
                child: BlocProvider(
                  create: (_) => RecordHFReferralBloc(
                    RecordHFReferralState.create(
                      projectId: widget.projectId,
                      viewOnly: widget.viewOnly,
                      hfReferralModel: widget.referralReconciliation,
                    ),
                    referralReconDataRepository: context.repository<
                        HFReferralModel, HFReferralSearchModel>(context),
                  ),
                  child: const AutoRouter(),
                ),
              ),
            ),
          ));
    }
  }
}
