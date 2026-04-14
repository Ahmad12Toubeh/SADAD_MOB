import '../../../../shared/widgets/feature_placeholder_page.dart';

class AssociationDetailsPage extends FeaturePlaceholderPage {
  AssociationDetailsPage({
    super.key,
    required String associationId,
  }) : super(
          title: 'Association Details',
          description:
              'This page mirrors SADAD_web route /dashboard/associations/$associationId and is ready for the Flutter detail experience.',
        );
}
