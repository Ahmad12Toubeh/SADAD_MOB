import '../../../../shared/widgets/feature_placeholder_page.dart';

class GuarantorDetailsPage extends FeaturePlaceholderPage {
  GuarantorDetailsPage({
    super.key,
    required String guarantorId,
  }) : super(
          title: 'Guarantor Details',
          description:
              'This page mirrors SADAD_web route /dashboard/guarantors/$guarantorId and is ready for the Flutter detail experience.',
        );
}
