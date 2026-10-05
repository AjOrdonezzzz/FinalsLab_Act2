import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'boxes.dart';
import 'task.dart';

// Soft pastel palette
class Pastel {
  static const bg = Color(0xFFF6F4FB);
  static const lavender = Color(0xFFD9D4F7);
  static const blue = Color(0xFFCFE0FB);
  static const mint = Color(0xFFCDEEE2);
  static const yellow = Color(0xFFFCF1B8);
  static const pink = Color(0xFFFBD3E9);
  static const ink = Color(0xFF3B3A4F);
  static const inkSoft = Color(0xFF7C7A92);
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning';
    if (h < 18) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _dateLabel(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return '${days[d.weekday - 1]}, ${d.day} ${months[d.month - 1]} ${d.year}';
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: Pastel.bg,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTask(context),
        backgroundColor: const Color(0xFF8E85E0),
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: const Icon(Icons.add_rounded, size: 28),
      ),
      body: SafeArea(
        child: ValueListenableBuilder<Box<Task>>(
          valueListenable: boxTaks.listenable(),
          builder: (context, box, _) {
            final all = box.values.toList();
            final today = all.where((t) => _isSameDay(t.dueDate, now)).toList();
            final overdue = all
                .where((t) =>
                    !t.isCompleted &&
                    t.dueDate.isBefore(DateTime(now.year, now.month, now.day)))
                .length;
            final scheduled = all
                .where((t) =>
                    !t.isCompleted &&
                    t.dueDate.isAfter(
                        DateTime(now.year, now.month, now.day, 23, 59, 59)))
                .length;
            final doneToday = today.where((t) => t.isCompleted).length;

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
              children: [
                // ---------- Welcome message ----------
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_greeting()}! 👋',
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              color: Pastel.ink,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _dateLabel(now),
                            style: const TextStyle(
                                fontSize: 14, color: Pastel.inkSoft),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.notifications_none_rounded,
                          color: Pastel.ink),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ---------- Progress card ----------
                _ProgressCard(done: doneToday, total: today.length),
                const SizedBox(height: 16),

                // ---------- Stat tiles ----------
                Row(
                  children: [
                    Expanded(
                        child: _StatTile(
                            label: 'Today',
                            count: today.length,
                            color: Pastel.blue,
                            icon: Icons.today_rounded)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _StatTile(
                            label: 'Scheduled',
                            count: scheduled,
                            color: Pastel.yellow,
                            icon: Icons.schedule_rounded)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                        child: _StatTile(
                            label: 'All',
                            count: all.length,
                            color: Pastel.mint,
                            icon: Icons.all_inbox_rounded)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _StatTile(
                            label: 'Overdue',
                            count: overdue,
                            color: Pastel.pink,
                            icon: Icons.error_outline_rounded)),
                  ],
                ),
                const SizedBox(height: 24),

                // ---------- Today's tasks ----------
                const Text(
                  "Today's Tasks",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Pastel.ink),
                ),
                const SizedBox(height: 12),
                if (today.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Center(
                      child: Text('No tasks for today 🎉',
                          style: TextStyle(color: Pastel.inkSoft)),
                    ),
                  )
                else
                  ...today.map((task) {
                    final index = all.indexOf(task);
                    return Dismissible(
                      key: ValueKey(task.id),
                      direction: DismissDirection.horizontal,
                      background: const _SwipeBackground(
                          alignment: Alignment.centerLeft),
                      secondaryBackground: const _SwipeBackground(
                          alignment: Alignment.centerRight),
                      onDismissed: (_) {
                        final i = box.values
                            .toList()
                            .indexWhere((t) => t.id == task.id);
                        if (i != -1) box.deleteAt(i);
                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                            SnackBar(
                              content: Text('"${task.title}" deleted'),
                              behavior: SnackBarBehavior.floating,
                              action: SnackBarAction(
                                label: 'Undo',
                                onPressed: () => box.add(task),
                              ),
                            ),
                          );
                      },
                      child: _TaskTile(
                        task: task,
                        onToggle: (v) {
                          task.isCompleted = v ?? false;
                          box.putAt(index, task);
                        },
                      ),
                    );
                  }),
              ],
            );
          },
        ),
      ),
    );
  }
}

void _showAddTask(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => const _AddTaskSheet(),
  );
}

class _AddTaskSheet extends StatefulWidget {
  const _AddTaskSheet();

  @override
  State<_AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<_AddTaskSheet> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _assigneeCtrl = TextEditingController();
  DateTime _dueDate = DateTime.now();
  TimeOfDay? _time;
  String _priority = 'Medium';
  String _category = 'General';

  static const _priorities = ['Low', 'Medium', 'High'];
  static const _categories = [
    'General',
    'Work',
    'Home',
    'Educational',
    'Grocery'
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _assigneeCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => _time = picked);
  }

  void _save() {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a task title')),
      );
      return;
    }
    boxTaks.add(Task(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      description: _descCtrl.text.trim(),
      dueDate: _dueDate,
      priority: _priority,
      category: _category,
      dueTime: _time?.format(context) ?? '',
      assignee: _assigneeCtrl.text.trim(),
    ));
    Navigator.pop(context);
  }

  InputDecoration _decoration(String label) => InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Pastel.bg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final d = _dueDate;
    final dateText =
        '${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}/${d.year}';

    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(
              child: Text('Add New Task',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Pastel.ink)),
            ),
            const SizedBox(height: 16),
            TextField(controller: _titleCtrl, decoration: _decoration('Title')),
            const SizedBox(height: 12),
            TextField(
              controller: _descCtrl,
              maxLines: 2,
              decoration: _decoration('Description (optional)'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(16),
                    child: InputDecorator(
                      decoration: _decoration('Due Date').copyWith(
                          suffixIcon: const Icon(Icons.calendar_today_rounded,
                              size: 18)),
                      child: Text(dateText),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: _pickTime,
                    borderRadius: BorderRadius.circular(16),
                    child: InputDecorator(
                      decoration: _decoration('Time (optional)').copyWith(
                          suffixIcon:
                              const Icon(Icons.access_time_rounded, size: 18)),
                      child: Text(_time?.format(context) ?? '--:-- --'),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _priority,
                    decoration: _decoration('Priority'),
                    items: _priorities
                        .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                        .toList(),
                    onChanged: (v) => setState(() => _priority = v!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _category,
                    decoration: _decoration('Category'),
                    items: _categories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => setState(() => _category = v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _assigneeCtrl,
              decoration: _decoration('Assignee (optional)'),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8E85E0),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final int done;
  final int total;
  const _ProgressCard({required this.done, required this.total});

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : done / total;
    final percent = (progress * 100).round();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Pastel.lavender, Pastel.blue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Pastel.lavender.withOpacity(0.5),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Today's Progress",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Pastel.ink),
                ),
                const SizedBox(height: 6),
                Text(
                  total == 0
                      ? 'Nothing planned yet'
                      : '$done of $total tasks completed',
                  style: const TextStyle(fontSize: 13, color: Pastel.inkSoft),
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    backgroundColor: Colors.white.withOpacity(0.6),
                    valueColor: const AlwaysStoppedAnimation(Color(0xFF8E85E0)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          SizedBox(
            width: 64,
            height: 64,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 6,
                  backgroundColor: Colors.white.withOpacity(0.6),
                  valueColor: const AlwaysStoppedAnimation(Color(0xFF8E85E0)),
                ),
                Text('$percent%',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, color: Pastel.ink)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData icon;
  const _StatTile({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                    color: Colors.white70, shape: BoxShape.circle),
                child: Icon(icon, size: 18, color: Pastel.ink),
              ),
              Text('$count',
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Pastel.ink)),
            ],
          ),
          Text(label,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Pastel.ink)),
        ],
      ),
    );
  }
}

class _SwipeBackground extends StatelessWidget {
  final Alignment alignment;
  const _SwipeBackground({required this.alignment});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      alignment: alignment,
      decoration: BoxDecoration(
        color: Pastel.pink,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Icon(Icons.delete_outline_rounded,
          color: Color(0xFFD6457F), size: 28),
    );
  }
}

class _TaskTile extends StatelessWidget {
  final Task task;
  final ValueChanged<bool?> onToggle;
  const _TaskTile({required this.task, required this.onToggle});

  Color _priorityColor(String p) {
    switch (p.toLowerCase()) {
      case 'high':
        return Pastel.pink;
      case 'low':
        return Pastel.mint;
      default:
        return Pastel.yellow;
    }
  }

  String _dueText(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  Widget _chip(String label, Color color, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: Pastel.ink),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600, color: Pastel.ink),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final done = task.isCompleted;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(4, 8, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: done,
            onChanged: onToggle,
            activeColor: const Color(0xFF8E85E0),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: done ? Pastel.inkSoft : Pastel.ink,
                      decoration: done ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  if (task.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      task.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style:
                          const TextStyle(fontSize: 13, color: Pastel.inkSoft),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _chip('${task.priority} priority',
                          _priorityColor(task.priority),
                          icon: Icons.flag_rounded),
                      _chip(task.category, Pastel.lavender,
                          icon: Icons.folder_open_rounded),
                      _chip(_dueText(task.dueDate), Pastel.blue,
                          icon: Icons.calendar_today_rounded),
                      if (task.dueTime.isNotEmpty)
                        _chip(task.dueTime, Pastel.blue,
                            icon: Icons.access_time_rounded),
                      if (task.assignee.isNotEmpty)
                        _chip(task.assignee, Pastel.mint,
                            icon: Icons.person_outline_rounded),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
