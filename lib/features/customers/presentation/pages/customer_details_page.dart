import '../../../../shared/widgets/feature_placeholder_page.dart';

class CustomerDetailsPage extends FeaturePlaceholderPage {
  CustomerDetailsPage({
    super.key,
    required String customerId,
  }) : super(
          title: 'Customer Details',
          description:
              'This page mirrors SADAD_web route /dashboard/customers/$customerId and is ready for the Flutter detail experience.',
        );
}
