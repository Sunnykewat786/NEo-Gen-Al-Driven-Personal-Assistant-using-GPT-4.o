/// Represents the data for an onboarding screen item.
class Onboard {
  /// The title of the onboarding screen.
  final String title;

  /// The subtitle or description of the onboarding screen.
  final String subtitle;

  /// The name of the Lottie animation file (without the extension).
  final String lottie;

  /// Constructor for the [Onboard] class.
  const Onboard({
    required this.title,
    required this.subtitle,
    required this.lottie,
  });
}
