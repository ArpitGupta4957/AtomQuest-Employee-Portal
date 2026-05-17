import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/providers/goal_provider.dart';
import '../../../core/models/enums.dart';
import '../../../core/widgets/shared_widgets.dart';

class MyGoalsScreen extends StatefulWidget {
  const MyGoalsScreen({super.key});

  @override
  State<MyGoalsScreen> createState() => _MyGoalsScreenState();
}

class _MyGoalsScreenState extends State<MyGoalsScreen> {
  GoalStatus? _selectedStatusFilter;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final goalProvider = context.watch<GoalProvider>();
    final isDesktop = MediaQuery.of(context).size.width >= 1024;

    // Filter goals
    var displayGoals = goalProvider.goals;
    if (_selectedStatusFilter != null) {
      displayGoals = displayGoals
          .where((g) => g.status == _selectedStatusFilter)
          .toList();
    }
    if (_searchQuery.isNotEmpty) {
      displayGoals = displayGoals
          .where(
            (g) =>
                g.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                g.description.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ),
          )
          .toList();
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(
          isDesktop ? AppSpacing.marginDesktop : AppSpacing.marginMobile,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSpacing.containerMax),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'My Goals',
                          style:
                              (isDesktop
                                      ? AppTypography.headlineLg
                                      : AppTypography.headlineLgMobile)
                                  .copyWith(color: AppColors.onBackground),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Manage and track your individual performance objectives.',
                          style: AppTypography.bodyLg.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () => context.go('/employee/goals/create'),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Create Goal'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryContainer,
                      foregroundColor: AppColors.textCharcoal,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // ── Filters & Stats ──
              Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('All', null),
                          const SizedBox(width: 8),
                          _buildFilterChip('Draft', GoalStatus.draft),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            'In Progress',
                            GoalStatus.inProgress,
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            'Pending Approval',
                            GoalStatus.pendingApproval,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Total Weightage: ${goalProvider.totalWeightage.toInt()}% / 100%',
                    style: AppTypography.labelMd.copyWith(
                      color: goalProvider.totalWeightage == 100
                          ? AppColors.successDeep
                          : AppColors.warningDeep,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Search Bar ──
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search goals by title or description...',
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.textMuted,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    borderSide: const BorderSide(color: AppColors.surfaceDim),
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceWhite,
                ),
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
              ),
              const SizedBox(height: 24),

              // ── Goal List ──
              if (displayGoals.isEmpty)
                const EmptyStateWidget(
                  icon: Icons.track_changes_outlined,
                  title: 'No goals found',
                  subtitle:
                      'Create a new goal to start tracking your performance.',
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: displayGoals.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) {
                    final goal = displayGoals[index];
                    return _GoalListItem(
                      goal: goal,
                      onTap: () => context.go('/employee/goals/${goal.id}'),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, GoalStatus? status) {
    final isSelected = _selectedStatusFilter == status;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedStatusFilter = selected ? status : null;
        });
      },
      backgroundColor: AppColors.surfaceWhite,
      selectedColor: AppColors.primaryContainer,
      labelStyle: AppTypography.labelSm.copyWith(
        color: isSelected
            ? AppColors.onPrimaryContainer
            : AppColors.onSurfaceVariant,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.surfaceContainer,
        ),
      ),
      showCheckmark: false,
    );
  }
}

class _GoalListItem extends StatefulWidget {
  final dynamic
  goal; // Uses dynamic here to avoid importing specific model file if there are conflicts, but we'll cast it conceptually
  final VoidCallback onTap;

  const _GoalListItem({required this.goal, required this.onTap});

  @override
  State<_GoalListItem> createState() => _GoalListItemState();
}

class _GoalListItemState extends State<_GoalListItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(
              color: _isHovered
                  ? AppColors.primaryContainer
                  : AppColors.surfaceContainer,
              width: _isHovered ? 2 : 1,
            ),
            boxShadow: [
              if (_isHovered)
                const BoxShadow(
                  color: Color(0x0A1F2937),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thrust Area Icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Icon(
                  widget.goal.isShared
                      ? Icons.share_outlined
                      : Icons.flag_outlined,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),

              // Main Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.goal.title,
                            style: AppTypography.headlineSm.copyWith(
                              color: AppColors.onBackground,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        StatusChip(status: widget.goal.status),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.goal.description,
                      style: AppTypography.bodyMd.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _buildMetaBadge('Weightage: ${widget.goal.weightage}%'),
                        _buildMetaBadge(
                          'Target: ${widget.goal.target} ${widget.goal.uomType.name}',
                        ),
                        _buildMetaBadge(
                          'Due: ${DateFormat('MMM d').format(widget.goal.targetDate)}',
                        ),
                        if (widget.goal.isShared) ...[
                          const Icon(
                            Icons.people,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          Text(
                            'Shared',
                            style: AppTypography.labelSm.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Progress
              const SizedBox(width: AppSpacing.xl),
              SizedBox(
                width: 120,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${widget.goal.progressPercent.toInt()}%',
                      style: AppTypography.headlineMd.copyWith(
                        color: AppColors.onBackground,
                      ),
                    ),
                    const SizedBox(height: 8),
                    AppProgressBar(progress: widget.goal.progressPercent),
                    const SizedBox(height: 8),
                    Text(
                      'Achieved',
                      style: AppTypography.labelSm.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetaBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: AppTypography.bodySm.copyWith(
          color: AppColors.textMuted,
          fontSize: 11,
        ),
      ),
    );
  }
}
