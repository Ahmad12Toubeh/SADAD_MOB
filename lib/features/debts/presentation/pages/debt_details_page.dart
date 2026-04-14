import '../../../../shared/widgets/feature_placeholder_page.dart';

class DebtDetailsPage extends FeaturePlaceholderPage {
  DebtDetailsPage({
    super.key,
    required String debtId,
  }) : super(
          title: 'Debt Details',
          description:
              'This page mirrors SADAD_web route /dashboard/debts/$debtId and is ready for the Flutter detail experience.',
        );
}
