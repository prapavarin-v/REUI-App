import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../services/firestore_service.dart';
import '../../models/misc_models.dart';

class ReservationScreen extends StatefulWidget {
  final String reservationId;
  const ReservationScreen({super.key, required this.reservationId});

  @override
  State<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  final _firestoreService = FirestoreService();
  final _locationController = TextEditingController();
  DateTime? _meetupTime;

  Future<void> _pickMeetupTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
        context: context, initialTime: TimeOfDay.now());
    if (time == null) return;
    setState(() {
      _meetupTime =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _confirmMeetup() async {
    if (_locationController.text.trim().isEmpty || _meetupTime == null) return;
    await _firestoreService.updateMeetup(
      reservationId: widget.reservationId,
      location: _locationController.text.trim(),
      time: _meetupTime!,
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('การจอง / นัดรับ')),
      body: StreamBuilder<ReservationModel?>(
        stream: _firestoreService.streamReservation(widget.reservationId),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final reservation = snapshot.data!;
          final isSeller = reservation.sellerId == uid;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(reservation.productTitle, style: AppTextStyles.h2),
                const SizedBox(height: AppSpacing.lg),
                _Timeline(currentStatus: reservation.status),
                const SizedBox(height: AppSpacing.lg),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(AppRadius.card),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('สถานที่นัดรับ',
                          style: AppTextStyles.bodyBold),
                      Text(
                          reservation.meetupLocation.isEmpty
                              ? 'ยังไม่ได้กำหนด'
                              : reservation.meetupLocation,
                          style: AppTextStyles.body),
                      const SizedBox(height: AppSpacing.sm),
                      Text('วัน/เวลา', style: AppTextStyles.bodyBold),
                      Text(
                          reservation.meetupTime == null
                              ? 'ยังไม่ได้กำหนด'
                              : DateFormat('d MMM y, HH:mm')
                                  .format(reservation.meetupTime!),
                          style: AppTextStyles.body),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                if (isSeller &&
                    reservation.status == ReservationStatus.requested) ...[
                  Text('นัดรับสินค้า', style: AppTextStyles.h3),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: _locationController,
                    decoration:
                        const InputDecoration(labelText: 'สถานที่นัดรับ'),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.schedule),
                    label: Text(_meetupTime == null
                        ? 'เลือกวัน/เวลานัดรับ'
                        : DateFormat('d MMM y, HH:mm').format(_meetupTime!)),
                    onPressed: _pickMeetupTime,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ElevatedButton(
                      onPressed: _confirmMeetup, child: const Text('ยืนยันนัดรับ')),
                ],
                if (reservation.status == ReservationStatus.waiting ||
                    reservation.status == ReservationStatus.meetup) ...[
                  ElevatedButton(
                    onPressed: () => _firestoreService.updateReservationStatus(
                        reservation.id, ReservationStatus.completed,
                        productId: reservation.productId),
                    child: const Text('ยืนยันว่ารับสินค้าสำเร็จ'),
                  ),
                ],
                const SizedBox(height: AppSpacing.sm),
                if (reservation.status != ReservationStatus.completed &&
                    reservation.status != ReservationStatus.cancelled)
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error)),
                    onPressed: () => _firestoreService.updateReservationStatus(
                        reservation.id, ReservationStatus.cancelled,
                        productId: reservation.productId),
                    child: const Text('ยกเลิกการจอง'),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Timeline extends StatelessWidget {
  final String currentStatus;
  const _Timeline({required this.currentStatus});

  @override
  Widget build(BuildContext context) {
    final steps = ReservationStatus.timelineOrder;
    final currentIndex = steps.indexOf(currentStatus);

    return Row(
      children: List.generate(steps.length, (i) {
        final active = i <= currentIndex;
        return Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  if (i != 0)
                    Expanded(
                      child: Container(
                          height: 2,
                          color: active ? AppColors.primary : AppColors.background),
                    ),
                  CircleAvatar(
                    radius: 12,
                    backgroundColor:
                        active ? AppColors.primary : AppColors.background,
                    child: Icon(
                        active ? Icons.check : Icons.circle,
                        size: 12,
                        color: active ? AppColors.white : AppColors.secondary),
                  ),
                  if (i != steps.length - 1)
                    Expanded(
                      child: Container(
                          height: 2,
                          color: i < currentIndex
                              ? AppColors.primary
                              : AppColors.background),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(ReservationStatus.label(steps[i]),
                  style: AppTextStyles.caption,
                  textAlign: TextAlign.center),
            ],
          ),
        );
      }),
    );
  }
}
