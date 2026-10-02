import 'package:ds/ds.dart';
import 'package:material_ui/material_ui.dart';

/// Every component, in groups, as one design system would draw it. Used by
/// the golden matrix (every system × light/dark) and by previews.
abstract final class Showcase {
  static const groups = {
    'actions': actions,
    'money': money,
    'objects': objects,
    'lists': lists,
    'inputs': inputs,
    'navigation': navigation,
    'pay': pay,
  };

  static const cards = [
    DsCardData(
      id: 'daily',
      field: DsField.yellow,
      institution: 'Techcombank',
      name: 'Chi tiêu hằng ngày',
      balance: 12450000,
      last4: '4821',
    ),
    DsCardData(
      id: 'home',
      field: DsField.green,
      institution: 'Vietcombank',
      name: 'Tiết kiệm mua nhà',
      balance: 86000000,
      last4: '0937',
    ),
    DsCardData(
      id: 'trip',
      field: DsField.blue,
      institution: 'TPBank',
      name: 'Du lịch Đà Nẵng',
      balance: 6130000,
      last4: '2210',
    ),
  ];

  static Widget actions() => Builder(
    builder: (context) {
      final ds = context.ds;
      void noop() {}
      return _column([
        _wrap([
          DsButton(
            label: 'Gửi 250.000 ₫',
            variant: DsButtonVariant.prominent,
            size: DsButtonSize.lg,
            icon: ds.icons.send,
            onPressed: noop,
          ),
          DsButton(label: 'Nạp tiền', icon: ds.icons.plus, onPressed: noop),
        ]),
        _wrap([
          DsButton(
            label: 'Sao chép',
            variant: DsButtonVariant.soft,
            onPressed: noop,
          ),
          DsButton(
            label: 'Xem tất cả',
            variant: DsButtonVariant.plain,
            size: DsButtonSize.sm,
            onPressed: noop,
          ),
          DsButton(
            label: 'Khoá thẻ',
            variant: DsButtonVariant.destructive,
            icon: ds.icons.lock,
            onPressed: noop,
          ),
        ]),
        _wrap([
          DsButton(label: 'Đang gửi…', loading: true, onPressed: noop),
          const DsButton(label: 'Hết hạn mức', onPressed: null),
        ]),
        _wrap([
          for (final v in DsIconButtonVariant.values)
            DsIconButton(
              icon: ds.icons.bell,
              label: v.name,
              variant: v,
              badge: v == DsIconButtonVariant.surface,
              onPressed: noop,
            ),
        ]),
        _wrap([
          DsChip(
            label: '+1.200.000 ₫ tháng này',
            icon: ds.icons.trendUp,
            tone: DsChipTone.positive,
          ),
          DsChip(label: '+500K', onPressed: noop),
          const DsChip(label: 'Mới', tone: DsChipTone.accent),
        ]),
        _wrap([
          DsToggle(value: true, onChanged: (_) {}),
          DsToggle(value: false, onChanged: (_) {}),
          const DsToggle(value: true, onChanged: null),
        ]),
        DsSegmentedControl<int>(
          segments: const [
            DsSegment(0, 'Tuần'),
            DsSegment(1, 'Tháng'),
            DsSegment(2, 'Năm'),
          ],
          value: 1,
          onChanged: (_) {},
        ),
      ]);
    },
  );

  static Widget money() => _column([
    const DsMoney(24580000, size: DsMoneySize.hero),
    const DsMoney(12450000, size: DsMoneySize.card),
    _wrap(const [
      DsMoney(-65000, sign: true),
      DsMoney(18500000, sign: true),
      DsMoney(24580000, hidden: true),
    ]),
  ]);

  static Widget objects() => Builder(
    builder: (context) {
      final ds = context.ds;
      void noop() {}
      return _column([
        DsAccountCard(data: cards.first, onTap: noop),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: ds.size.cardAspect,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            for (final f in DsField.values)
              DsAccountCard(
                size: DsCardSize.sm,
                data: DsCardData(
                  id: f.name,
                  field: f,
                  name: f.name,
                  balance: f == DsField.graphite ? -4250000 : 3200000,
                ),
              ),
          ],
        ),
        DsCardStack(cards: cards, onOpen: (_) {}),
        _wrap([
          DsIconTile.glyph(
            field: DsField.red,
            icon: ds.icons.send,
            label: 'Chuyển tiền',
            onTap: noop,
          ),
          DsIconTile.glyph(
            field: DsField.green,
            icon: ds.icons.topUp,
            label: 'Nạp tiền',
            onTap: noop,
          ),
          DsIconTile.glyph(
            field: DsField.blue,
            icon: ds.icons.scan,
            label: 'Quét QR',
            onTap: noop,
          ),
          DsIconTile.glyph(
            field: DsField.purple,
            icon: ds.icons.bill,
            label: 'Hoá đơn',
            onTap: noop,
          ),
        ]),
        _wrap([
          for (final e in DsEmoji.values.take(5))
            DsIconTile.emoji(emoji: e, label: e.name),
        ]),
      ]);
    },
  );

  static Widget lists() => Builder(
    builder: (context) {
      final ds = context.ds;
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DsListSection.plain(
            header: 'Hoạt động',
            actionLabel: 'Xem tất cả',
            onAction: () {},
            children: [
              DsListItem.content(
                title: 'Highlands Coffee',
                subtitle: 'Cà phê · 08:42',
                emoji: DsEmoji.hotBeverage,
                account: DsField.yellow,
                amount: -65000,
                onTap: () {},
              ),
              const DsListItem.content(
                title: 'Lương tháng 9',
                subtitle: 'Thu nhập · 30/09',
                emoji: DsEmoji.moneyBag,
                account: DsField.green,
                amount: 18500000,
              ),
              const DsListItem.content(
                title: 'Hoà Chu',
                subtitle: 'Chuyển tiền · Hôm qua',
                monogram: 'HC',
                amount: -250000,
              ),
            ],
          ),
          SizedBox(height: ds.spacing.s8),
          DsListSection.grouped(
            header: 'Bảo mật',
            footer: 'Face ID được dùng khi thanh toán.',
            children: [
              DsListItem.settings(
                title: 'Đổi mã PIN',
                glyph: ds.icons.lock,
                accessory: DsAccessory.chevron,
                onTap: () {},
              ),
              DsListItem.settings(
                title: 'Ngôn ngữ',
                glyph: ds.icons.language,
                value: 'Tiếng Việt',
                accessory: DsAccessory.chevron,
                onTap: () {},
              ),
              DsListItem.settings(
                title: 'Face ID khi thanh toán',
                glyph: ds.icons.eye,
                trailing: DsToggle(value: true, onChanged: (_) {}),
              ),
              DsListItem.settings(
                title: 'Đăng xuất',
                glyph: ds.icons.logout,
                destructive: true,
                onTap: () {},
              ),
            ],
          ),
          SizedBox(height: ds.spacing.s8),
          const DsListSection.plain(
            header: 'Tiết kiệm',
            empty: DsEmptyState(
              title: 'Chưa có giao dịch',
              message: 'Khoản tiết kiệm đầu tiên sẽ hiện ở đây.',
            ),
            children: [],
          ),
        ],
      );
    },
  );

  static Widget inputs() => _column([
    const DsTextField(label: 'Ghi chú', placeholder: 'Cà phê sáng nay'),
    DsTextField(
      label: 'Số tài khoản',
      controller: TextEditingController(text: '12345'),
      error: 'Số tài khoản gồm 9 đến 14 chữ số.',
    ),
    DsAmountField(
      value: 250000,
      onChanged: (_) {},
      available: 12450000,
      sourceField: DsField.yellow,
      sourceName: 'Chi tiêu hằng ngày',
    ),
    DsAmountField(
      value: 15000000,
      onChanged: (_) {},
      available: 12450000,
      sourceField: DsField.yellow,
      sourceName: 'Chi tiêu hằng ngày',
      label: 'Số tiền',
    ),
  ]);

  static Widget navigation() => Builder(
    builder: (context) {
      final ds = context.ds;
      void noop() {}
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DsNavigationBar.home(
            initials: 'LN',
            greeting: 'Chào buổi sáng',
            name: 'Lan Nguyen',
            actions: [
              DsIconButton(
                icon: ds.icons.search,
                label: 'Tìm',
                onPressed: noop,
              ),
              DsIconButton(
                icon: ds.icons.bell,
                label: 'Thông báo',
                badge: true,
                onPressed: noop,
              ),
            ],
          ),
          const DsNavigationBar.large(title: 'Thẻ của tôi'),
          DsNavigationBar.inline(title: 'Chi tiết', onBack: noop),
          DsNavigationBar.inline(
            title: 'Chi tiết',
            onBack: noop,
            scrolled: true,
          ),
          SizedBox(height: ds.spacing.s4),
          DsTabBar(
            index: 0,
            onChanged: (_) {},
            items: [
              DsTabItem(icon: ds.icons.home, label: 'Trang chủ'),
              DsTabItem(icon: ds.icons.cards, label: 'Thẻ'),
              DsTabItem(icon: ds.icons.activity, label: 'Hoạt động'),
              DsTabItem(icon: ds.icons.profile, label: 'Cá nhân'),
            ],
          ),
          DsSheet(
            title: 'Chuyển tiền',
            onClose: noop,
            footer: DsButton(
              label: 'Gửi 250.000 ₫',
              variant: DsButtonVariant.prominent,
              size: DsButtonSize.lg,
              block: true,
              onPressed: noop,
            ),
            child: const DsTextField(label: 'Ghi chú', placeholder: 'Ăn trưa'),
          ),
        ],
      );
    },
  );

  static Widget pay() => _column(const [
    DsTapToPay(
      card: DsCardData(
        id: 'daily',
        field: DsField.yellow,
        institution: 'Techcombank',
        name: 'Chi tiêu hằng ngày',
        balance: 12450000,
        last4: '4821',
      ),
      status: DsPayStatus.success,
      amount: 65000,
      readyLabel: 'Giữ mặt sau điện thoại gần máy POS',
      successLabel: 'Đã thanh toán',
      merchant: 'Highlands Coffee',
    ),
  ]);

  static Widget _column(List<Widget> children) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (final (i, c) in children.indexed) ...[
        if (i > 0) const SizedBox(height: 16),
        c,
      ],
    ],
  );

  static Widget _wrap(List<Widget> children) => Wrap(
    spacing: 8,
    runSpacing: 8,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: children,
  );
}
