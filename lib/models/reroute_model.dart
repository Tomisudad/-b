/// V5.5 改道记录模型 — 导航页与总结页共享
class RerouteAction {
  final String action;
  final double newDistanceKm;
  final double originalDistanceKm;

  const RerouteAction(this.action, this.newDistanceKm, this.originalDistanceKm);
}
