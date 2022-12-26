// Calculate Calories Burned
double calCalBurnedForJumpRope(int duration, int count, double weight) {
  double time = duration / 30 * 0.5;
  double kcal = (11.8 * 60 * 3.5 * time) / 200;
  return kcal;
}
