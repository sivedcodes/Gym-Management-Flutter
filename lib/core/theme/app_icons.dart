import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CENTRAL ICON MAP — ONE MEANING → ONE ICON.
// Screens must use AppIcons.*, never Icons.* directly.
// Pairs (outlined/rounded) mark unselected/selected states.
// ─────────────────────────────────────────────────────────────────────────────
abstract final class AppIcons {
  // ── Bottom navigation ──
  static const home = Icons.home_outlined;
  static const homeActive = Icons.home_rounded;
  static const programs = Icons.fitness_center_outlined;
  static const programsActive = Icons.fitness_center_rounded;
  static const music = Icons.headphones_outlined;
  static const musicActive = Icons.headphones_rounded;
  static const profile = Icons.person_outline_rounded;
  static const profileActive = Icons.person_rounded;
  static const dashboard = Icons.dashboard_outlined;
  static const dashboardActive = Icons.dashboard_rounded;
  static const pendingNav = Icons.pending_actions_outlined;
  static const pendingNavActive = Icons.pending_actions_rounded;
  static const members = Icons.people_outlined;
  static const membersActive = Icons.people_rounded;
  static const plans = Icons.card_membership_outlined;
  static const plansActive = Icons.card_membership_rounded;

  // ── Actions ──
  static const add = Icons.add_rounded;
  static const addCard = Icons.add_card_rounded;
  static const renew = Icons.autorenew_rounded;
  static const register = Icons.how_to_reg_outlined;
  static const demo = Icons.science_outlined;
  static const note = Icons.edit_note_rounded;
  static const edit = Icons.edit_outlined;
  static const close = Icons.close_rounded;
  static const check = Icons.check_rounded;
  static const search = Icons.search_rounded;
  static const searchOff = Icons.search_off_rounded;
  static const refresh = Icons.refresh_rounded;
  static const tune = Icons.tune_rounded;
  static const logout = Icons.logout_rounded;
  static const hide = Icons.visibility_off_outlined;
  static const show = Icons.visibility_outlined;
  static const next = Icons.chevron_right_rounded;
  static const forward = Icons.arrow_forward_rounded;
  static const bookmark = Icons.bookmark_outline_rounded;
  static const bookmarkActive = Icons.bookmark_rounded;
  static const history = Icons.history_rounded;
  static const send = Icons.send_rounded;

  // ── Entities ──
  static const member = Icons.person_outline_rounded;
  static const membership = Icons.card_membership_rounded;
  static const membershipOut = Icons.card_membership_outlined;
  static const training = Icons.fitness_center_rounded;
  static const diet = Icons.restaurant_menu_rounded;
  static const yoga = Icons.self_improvement_rounded;
  static const cardio = Icons.directions_run_rounded;
  static const physio = Icons.healing_outlined;
  static const genericProgram = Icons.star_outline_rounded;
  static const phone = Icons.smartphone_rounded;
  static const phoneAlt = Icons.phone_android_rounded;
  static const gym = Icons.storefront_outlined;
  static const qrShow = Icons.qr_code_2_rounded;
  static const qrScan = Icons.qr_code_scanner_rounded;
  static const calendar = Icons.calendar_month_outlined;
  static const rupee = Icons.currency_rupee_rounded;
  static const ticket = Icons.confirmation_number_outlined;
  static const payments = Icons.payments_outlined;
  static const label = Icons.label_outline_rounded;
  static const desc = Icons.description_outlined;
  static const category = Icons.category_outlined;
  static const bolt = Icons.bolt_rounded;
  static const verified = Icons.verified_outlined;

  // ── Program meta (booking detail rows) ──
  static const goal = Icons.track_changes_rounded;
  static const level = Icons.leaderboard_outlined;
  static const info = Icons.info_outline_rounded;
  static const weight = Icons.monitor_weight_outlined;
  static const height = Icons.height_outlined;

  // ── Media player ──
  static const play = Icons.play_arrow_rounded;
  static const queue = Icons.queue_music_rounded;
  static const album = Icons.album_outlined;
  static const songs = Icons.music_note_outlined;
  static const heart = Icons.favorite_rounded;
  static const heartOut = Icons.favorite_outline_rounded;
  static const fire = Icons.whatshot_rounded;
  static const timer = Icons.timer_outlined;
  static const pause = Icons.pause_rounded;
  static const playFill = Icons.play_circle_fill_rounded;
  static const pauseFill = Icons.pause_circle_filled_rounded;
  static const prev = Icons.skip_previous_rounded;
  static const nextTrack = Icons.skip_next_rounded;
  static const headphones = Icons.headphones_rounded;
  static const musicNote = Icons.music_note_rounded;
  static const liveEq = Icons.bar_chart_rounded;
  static const allEq = Icons.equalizer_rounded;

  // ── Status / states ──
  static const pending = Icons.hourglass_top_rounded;
  static const approved = Icons.check_circle_outline_rounded;
  static const approvedFill = Icons.task_alt_outlined;
  static const enrolled = Icons.check_circle_rounded;
  static const denied = Icons.cancel_outlined;
  static const activeDot = Icons.play_circle_outline_rounded;
  static const expired = Icons.timer_off_outlined;
  static const bell = Icons.notifications_outlined;
  static const bellRing = Icons.notifications_active_outlined;
  static const empty = Icons.person_search_outlined;
  static const offline = Icons.cloud_off_outlined;
  static const error = Icons.error_outline_rounded;

  /// Kind string (data, not enum) → icon. New categories fall back
  /// to [genericProgram] with zero code change.
  static IconData kindIcon(String kind) => switch (kind) {
        'training' => training,
        'diet' => diet,
        'yoga' => yoga,
        'cardio' => cardio,
        'physio' => physio,
        _ => genericProgram,
      };
}
