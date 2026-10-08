import 'package:flutter/cupertino.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DATA MODELS
// ─────────────────────────────────────────────────────────────────────────────

enum AvatarType { store, initials }

class MailItem {
  MailItem({
    required this.id,
    required this.sender,
    required this.time,
    required this.subject,
    required this.snippet,
    this.initials,
    this.avatarType = AvatarType.store,
    this.avatarColor = const Color(0xFFA855F7),
    this.isUnread = false,
    this.hasAttachment = false,
    this.hasReplied = false,
    this.body,
  });

  final String id;
  final String sender;
  final String time;
  final String subject;
  final String snippet;
  final String? initials;
  final AvatarType avatarType;
  final Color avatarColor;
  bool isUnread;
  final bool hasAttachment;
  final bool hasReplied;
  final String? body;
}

/// Model for items in the Mailboxes overview list.
class MailboxFolder {
  const MailboxFolder({
    required this.id,
    required this.title,
    required this.icon,
    this.iconColor = const Color(0xFF007AFF),
    this.count,
    this.isInbox = false,
  });

  final String id;
  final String title;
  final IconData icon;
  final Color iconColor;
  final int? count;
  final bool isInbox;
}

final List<MailItem> kInitialEmails = [
  MailItem(
    id: '1',
    sender: 'Apple',
    time: 'Yesterday',
    subject: 'Pre-order the new iPhone 18 Pro now.',
    snippet:
        '↳ iPhone 18 Pro and Max available starting 18.9; iPhone Duo available starting 23.10;...',
    avatarType: AvatarType.store,
    avatarColor: const Color(0xFFA855F7),
    isUnread: true,
    body:
        'Pre-order the new iPhone 18 Pro and iPhone 18 Pro Max today. Featuring next-generation Apple Silicon, spatial capture, and all-day battery life.',
  ),
  MailItem(
    id: '2',
    sender: 'Apple',
    time: 'Friday',
    subject: 'Get ready for iPhone 18 Pro pre-order now.',
    snippet:
        '↳ Express lane for check-out; pre-order iPhone 18 Pro on 12.9; pre-order iPhone...',
    avatarType: AvatarType.store,
    avatarColor: const Color(0xFFA855F7),
    isUnread: true,
    body:
        'Get set up ahead of time with Express Check-out so you can complete your order in seconds when pre-orders open.',
  ),
  MailItem(
    id: '3',
    sender: 'Apple',
    time: 'Thursday',
    subject: 'The most powerful iPhone line-up ever.',
    snippet:
        '↳ New products introduced; iPhone Duo, iPhone 18 Pro, Apple Watch Series 12; pre...',
    avatarType: AvatarType.store,
    avatarColor: const Color(0xFFA855F7),
    isUnread: true,
    body:
        'Catch up on all announcements from this week\'s Apple Special Event, including iPhone Duo and Apple Watch Series 12.',
  ),
  MailItem(
    id: '4',
    sender: 'Marcus Vance',
    time: 'Wednesday',
    subject: 'Project Nova Launch',
    snippet:
        '↳ The release branch is merged and ready for deployment to staging. All test suites pass...',
    initials: 'MV',
    avatarType: AvatarType.initials,
    avatarColor: const Color(0xFF3B82F6),
    isUnread: true,
    hasAttachment: true,
    body:
        'Team, the release branch for Project Nova is now merged. Please review the staging deployment logs before we initiate the final rollout tomorrow morning.',
  ),
  MailItem(
    id: '5',
    sender: 'Starlink',
    time: 'Tuesday',
    subject: 'Mini has arrived',
    snippet:
        '↳ Portability in your backpack; Compact, lightweight internet everywhere...',
    avatarType: AvatarType.store,
    avatarColor: const Color(0xFF6B7280),
    isUnread: true,
    body:
        'Starlink Mini fits seamlessly into your backpack and delivers high-speed, low-latency connectivity on the move.',
  ),
  MailItem(
    id: '6',
    sender: 'Sarah Jenkins',
    time: 'Sep 10',
    subject: 'Design tokens & Living Chrome specs',
    snippet:
        '↳ Hey! Here are the updated Figma tokens and glass shader configs for the 1.2.0 release...',
    initials: 'SJ',
    avatarType: AvatarType.initials,
    avatarColor: const Color(0xFFEC4899),
    hasAttachment: true,
    hasReplied: true,
    body:
        'Hey Alex, here are the updated design tokens for Living Chrome. We\'ve adjusted the specular highlight and blur presets to match the latest iOS 26 builds.',
  ),
  MailItem(
    id: '7',
    sender: 'GitHub',
    time: 'Sep 9',
    subject: '[liquid_glass_widgets] PR #182 merged',
    snippet:
        '↳ sdegenaar merged commit 4f9e12 into main: "Add GlassScaffold living chrome support"...',
    avatarType: AvatarType.store,
    avatarColor: const Color(0xFF24292F),
    body:
        'Pull request #182 has been merged into main. Automated checks have passed successfully.',
  ),
  MailItem(
    id: '8',
    sender: 'Stripe',
    time: 'Sep 8',
    subject: 'Monthly payout report for August 2026',
    snippet:
        '↳ Your payout of \$14,820.50 has been submitted to your bank account and is expected...',
    avatarType: AvatarType.store,
    avatarColor: const Color(0xFF635BFF),
    hasAttachment: true,
    body:
        'Your monthly payout has been processed. Detailed invoices and tax breakdowns are attached as PDF documents.',
  ),
];
