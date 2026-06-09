import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../features/credits/data/credits_mock_data.dart';
import '../../features/credits/domain/entities/installment.dart';
import '../../features/credits/domain/entities/loan.dart';
import '../../features/dashboard/data/dashboard_mock_data.dart';
import '../../features/dashboard/domain/entities/financial_summary.dart';
import '../../features/dashboard/domain/entities/movement.dart';
import '../../features/operations/data/operations_mock_data.dart';
import '../../features/operations/domain/entities/operation_history_item.dart';
import '../../features/operations/domain/entities/operation_contact.dart';
import '../../features/savings/data/savings_mock_data.dart';
import '../../features/savings/domain/entities/account_statement.dart';
import '../../features/savings/domain/entities/deposit.dart';
import '../../features/savings/domain/entities/savings_account.dart';
import '../errors/app_exception.dart';
import 'client_database_service.dart';
import 'firebase_auth_service.dart';

class FinancialFirestoreService {
  FinancialFirestoreService._();

  static final FinancialFirestoreService instance =
      FinancialFirestoreService._();

  static const num initialBalance = 1000;

  String? _ensuredClientId;
  Future<void>? _ensureProfileFuture;

  FirebaseFirestore? get _firestore {
    if (Firebase.apps.isEmpty) return null;
    return FirebaseFirestore.instance;
  }

  String get _clientId =>
      FirebaseAuthService.instance.currentUser?.uid ??
      ClientDatabaseService.instance.currentClient?.id ??
      'CLI-001';

  String get _today {
    final now = DateTime.now();
    return '${now.day}/${now.month}/${now.year}';
  }

  Future<void> ensureClientFinancialProfile() async {
    final firestore = _firestore;
    if (firestore == null) return;

    final clientId = _clientId;
    if (_ensuredClientId == clientId) return;

    final pendingEnsure = _ensureProfileFuture;
    if (pendingEnsure != null) return pendingEnsure;

    _ensureProfileFuture = _ensureClientFinancialProfile(
      firestore: firestore,
      clientId: clientId,
    );

    try {
      await _ensureProfileFuture;
      _ensuredClientId = clientId;
    } finally {
      _ensureProfileFuture = null;
    }
  }

  Future<void> _ensureClientFinancialProfile({
    required FirebaseFirestore firestore,
    required String clientId,
  }) async {
    final clientRef = firestore.collection('clients').doc(clientId);
    final savingsRef = clientRef.collection('savings').doc('main');

    await firestore.runTransaction((transaction) async {
      final clientDoc = await transaction.get(clientRef);
      final savingsDoc = await transaction.get(savingsRef);

      if (!clientDoc.exists) {
        transaction.set(clientRef, {
          'totalBalance': initialBalance,
          'savingsBalance': initialBalance,
          'activeLoansBalance': 0,
          'financialProfileSeeded': true,
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } else {
        final data = clientDoc.data() ?? {};
        final updates = <String, Object?>{};
        final hasSeededProfile =
            data['financialProfileSeeded'] as bool? ?? false;
        final totalBalance = data['totalBalance'] as num?;
        final savingsBalance = data['savingsBalance'] as num?;

        if (!hasSeededProfile && (totalBalance == null || totalBalance == 0)) {
          updates['totalBalance'] = initialBalance;
        }
        if (!hasSeededProfile &&
            (savingsBalance == null || savingsBalance == 0)) {
          updates['savingsBalance'] = initialBalance;
        }
        if (!data.containsKey('activeLoansBalance')) {
          updates['activeLoansBalance'] = 0;
        }
        if (!hasSeededProfile) {
          updates['financialProfileSeeded'] = true;
        }
        if (updates.isNotEmpty) transaction.update(clientRef, updates);
      }

      if (!savingsDoc.exists) {
        transaction.set(savingsRef, {
          'number': 'AHO-${clientId.substring(0, 6).toUpperCase()}',
          'balance': initialBalance,
          'status': 'Activa',
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        final savingsData = savingsDoc.data() ?? {};
        final clientData = clientDoc.data() ?? {};
        final hasSeededProfile = clientDoc.exists
            ? clientData['financialProfileSeeded'] as bool? ?? false
            : false;
        final balance = savingsData['balance'] as num?;
        if (!hasSeededProfile && (balance == null || balance == 0)) {
          transaction.update(savingsRef, {'balance': initialBalance});
        }
      }
    });
  }

  Future<FinancialSummary> getSummary() async {
    final firestore = _firestore;
    if (firestore == null) return DashboardMockData.summary;

    await ensureClientFinancialProfile();
    final doc = await firestore.collection('clients').doc(_clientId).get();
    final data = doc.data();
    if (data == null) {
      return const FinancialSummary(
        totalBalance: initialBalance,
        savingsBalance: initialBalance,
        activeLoansBalance: 0,
      );
    }

    return FinancialSummary(
      totalBalance: data['totalBalance'] as num? ?? initialBalance,
      savingsBalance: data['savingsBalance'] as num? ?? initialBalance,
      activeLoansBalance: data['activeLoansBalance'] as num? ?? 0,
    );
  }

  Future<List<Movement>> getMovements({int? limit}) async {
    final firestore = _firestore;
    if (firestore == null) return DashboardMockData.movements;

    await ensureClientFinancialProfile();
    Query<Map<String, dynamic>> query = firestore
        .collection('clients')
        .doc(_clientId)
        .collection('movements')
        .orderBy('createdAt', descending: true);

    if (limit != null) query = query.limit(limit);

    final snapshot = await query.get();
    if (snapshot.docs.isEmpty) return const [];

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Movement(
        title: data['title'] as String? ?? 'Movimiento',
        date: data['date'] as String? ?? '',
        amount: data['amount'] as num? ?? 0,
        isIncome: data['isIncome'] as bool? ?? false,
      );
    }).toList();
  }

  Future<SavingsAccount> getSavingsAccount() async {
    final firestore = _firestore;
    if (firestore == null) return SavingsMockData.account;

    await ensureClientFinancialProfile();
    final doc = await firestore
        .collection('clients')
        .doc(_clientId)
        .collection('savings')
        .doc('main')
        .get();

    final data = doc.data();
    if (data == null) return SavingsMockData.account;

    return SavingsAccount(
      number: data['number'] as String? ?? '',
      balance: data['balance'] as num? ?? initialBalance,
      status: data['status'] as String? ?? 'Activa',
    );
  }

  Future<List<Deposit>> getDeposits() async {
    final firestore = _firestore;
    if (firestore == null) return SavingsMockData.deposits;

    final snapshot = await firestore
        .collection('clients')
        .doc(_clientId)
        .collection('deposits')
        .orderBy('createdAt', descending: true)
        .get();

    if (snapshot.docs.isEmpty) return const [];

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Deposit(
        date: data['date'] as String? ?? '',
        amount: data['amount'] as num? ?? 0,
        reference: data['reference'] as String? ?? doc.id,
      );
    }).toList();
  }

  Future<List<AccountStatement>> getStatements() async {
    final firestore = _firestore;
    if (firestore == null) return SavingsMockData.statements;

    final snapshot = await firestore
        .collection('clients')
        .doc(_clientId)
        .collection('statements')
        .orderBy('createdAt', descending: true)
        .get();

    if (snapshot.docs.isEmpty) return const [];

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return AccountStatement(
        period: data['period'] as String? ?? '',
        openingBalance: data['openingBalance'] as num? ?? 0,
        closingBalance: data['closingBalance'] as num? ?? 0,
      );
    }).toList();
  }

  Future<Loan> getActiveLoan() async {
    final firestore = _firestore;
    if (firestore == null) return CreditsMockData.activeLoan;

    final doc = await firestore
        .collection('clients')
        .doc(_clientId)
        .collection('credits')
        .doc('activeLoan')
        .get();

    final data = doc.data();
    if (data == null) return CreditsMockData.activeLoan;

    return Loan(
      id: data['id'] as String? ?? doc.id,
      amount: data['amount'] as num? ?? 0,
      pendingBalance: data['pendingBalance'] as num? ?? 0,
      status: data['status'] as String? ?? 'Al día',
    );
  }

  Future<List<Installment>> getInstallments() async {
    final firestore = _firestore;
    if (firestore == null) return CreditsMockData.installments;

    final snapshot = await firestore
        .collection('clients')
        .doc(_clientId)
        .collection('installments')
        .orderBy('number')
        .get();

    if (snapshot.docs.isEmpty) return CreditsMockData.installments;

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Installment(
        number: data['number'] as int? ?? 0,
        dueDate: data['dueDate'] as String? ?? '',
        amount: data['amount'] as num? ?? 0,
        isPaid: data['isPaid'] as bool? ?? false,
      );
    }).toList();
  }

  Future<List<OperationHistoryItem>> getOperations() async {
    final firestore = _firestore;
    if (firestore == null) return OperationsMockData.history;

    await ensureClientFinancialProfile();
    final snapshot = await firestore
        .collection('clients')
        .doc(_clientId)
        .collection('operations')
        .orderBy('createdAt', descending: true)
        .get();

    if (snapshot.docs.isEmpty) return const [];

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return OperationHistoryItem(
        type: data['type'] as String? ?? 'Operación',
        date: data['date'] as String? ?? '',
        amount: data['amount'] as num? ?? 0,
        status: data['status'] as String? ?? 'Exitosa',
      );
    }).toList();
  }

  OperationContact _contactFromData(
    String id,
    Map<String, dynamic> data,
  ) {
    return OperationContact(
      id: id,
      fullName: data['fullName'] as String? ?? 'Cliente sin nombre',
      email: data['email'] as String? ?? '',
      documentNumber: data['documentNumber'] as String? ?? '',
      photoUrl: data['photoUrl'] as String?,
    );
  }

  Future<List<OperationContact>> searchContactsByName(String query) async {
    final firestore = _firestore;
    if (firestore == null) return const [];

    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.length < 2) return const [];

    final snapshot = await firestore.collection('clients').limit(50).get();
    return snapshot.docs
        .where((doc) => doc.id != _clientId)
        .map((doc) => _contactFromData(doc.id, doc.data()))
        .where(
          (contact) => contact.fullName.toLowerCase().contains(
            normalizedQuery,
          ),
        )
        .toList()
      ..sort((a, b) => a.fullName.compareTo(b.fullName));
  }

  Future<List<OperationContact>> getQuickAccessContacts() async {
    final firestore = _firestore;
    if (firestore == null) return const [];

    final snapshot = await firestore
        .collection('clients')
        .doc(_clientId)
        .collection('quickAccess')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => _contactFromData(doc.id, doc.data()))
        .toList();
  }

  Future<void> addQuickAccessContact(OperationContact contact) async {
    final firestore = _firestore;
    if (firestore == null) return;
    if (contact.id == _clientId) {
      throw const AppException('No puedes agregarte a tus accesos rápidos.');
    }

    final contactDoc = await firestore.collection('clients').doc(contact.id).get();
    if (!contactDoc.exists) {
      throw const AppException('El contacto seleccionado no existe.');
    }

    await firestore
        .collection('clients')
        .doc(_clientId)
        .collection('quickAccess')
        .doc(contact.id)
        .set({
          'fullName': contact.fullName,
          'email': contact.email,
          'documentNumber': contact.documentNumber,
          'photoUrl': contact.photoUrl,
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }

  Future<void> removeQuickAccessContact(String contactId) async {
    final firestore = _firestore;
    if (firestore == null) return;

    await firestore
        .collection('clients')
        .doc(_clientId)
        .collection('quickAccess')
        .doc(contactId)
        .delete();
  }

  Future<OperationContact> getContactById(String contactId) async {
    final firestore = _firestore;
    if (firestore == null) {
      throw const AppException('No se pudo validar el contacto.');
    }

    final doc = await firestore.collection('clients').doc(contactId).get();
    final data = doc.data();
    if (!doc.exists || data == null || contactId == _clientId) {
      throw const AppException('El contacto seleccionado no existe.');
    }
    return _contactFromData(doc.id, data);
  }

  Future<void> recordContactTransfer({
    required OperationContact contact,
    required num amount,
    required String description,
  }) async {
    final firestore = _firestore;
    if (firestore == null) return;
    if (amount <= 0) {
      throw const AppException('El monto debe ser mayor a cero.');
    }
    if (contact.id == _clientId) {
      throw const AppException('No puedes transferirte a tu propia cuenta.');
    }

    await ensureClientFinancialProfile();

    final senderRef = firestore.collection('clients').doc(_clientId);
    final recipientRef = firestore.collection('clients').doc(contact.id);
    final senderSavingsRef = senderRef.collection('savings').doc('main');
    final recipientSavingsRef = recipientRef.collection('savings').doc('main');
    final senderOperationRef = senderRef.collection('operations').doc();
    final senderMovementRef = senderRef.collection('movements').doc();
    final recipientMovementRef = recipientRef.collection('movements').doc();

    final senderDoc = await senderRef.get().timeout(const Duration(seconds: 10));
    final recipientDoc = await recipientRef
        .get()
        .timeout(const Duration(seconds: 10));

    final senderData = senderDoc.data() ?? {};
    final recipientData = recipientDoc.data();
    if (!recipientDoc.exists || recipientData == null) {
      throw const AppException('El contacto seleccionado no existe.');
    }

    final currentBalance = senderData['totalBalance'] as num? ?? initialBalance;
    if (currentBalance < amount) {
      throw const AppException(
        'Saldo insuficiente para realizar la operación.',
      );
    }

    final recipientBalance =
        recipientData['totalBalance'] as num? ?? initialBalance;
    final recipientSavingsBalance =
        recipientData['savingsBalance'] as num? ?? recipientBalance;
    final newSenderBalance = currentBalance - amount;
    final newRecipientBalance = recipientBalance + amount;
    final newRecipientSavingsBalance = recipientSavingsBalance + amount;
    final cleanDescription = description.trim();
    final batch = firestore.batch();

    batch.update(senderRef, {
      'totalBalance': newSenderBalance,
      'savingsBalance': newSenderBalance,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    batch.set(senderSavingsRef, {
      'balance': newSenderBalance,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    batch.set(recipientRef, {
      'totalBalance': newRecipientBalance,
      'savingsBalance': newRecipientSavingsBalance,
      'activeLoansBalance': recipientData['activeLoansBalance'] as num? ?? 0,
      'financialProfileSeeded': true,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    batch.set(recipientSavingsRef, {
      'balance': newRecipientSavingsBalance,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    batch.set(senderOperationRef, {
      'type': 'Transferencia',
      'amount': amount,
      'status': 'Exitosa',
      'date': _today,
      'createdAt': FieldValue.serverTimestamp(),
      'recipientId': contact.id,
      'recipientName': contact.fullName,
      'description': cleanDescription,
    });
    batch.set(senderMovementRef, {
      'title': 'Transferencia a ${contact.fullName}',
      'amount': amount,
      'date': _today,
      'isIncome': false,
      'createdAt': FieldValue.serverTimestamp(),
      'recipientId': contact.id,
      'recipientName': contact.fullName,
      'description': cleanDescription,
    });
    batch.set(recipientMovementRef, {
      'title': 'Depósito de usuario',
      'amount': amount,
      'date': _today,
      'isIncome': true,
      'createdAt': FieldValue.serverTimestamp(),
      'senderId': _clientId,
      'description': cleanDescription,
    });
    await batch.commit().timeout(const Duration(seconds: 12));
  }

  Future<void> recordOperation({
    required String type,
    required num amount,
    required Map<String, Object?> detail,
  }) async {
    final firestore = _firestore;
    if (firestore == null) return;
    if (amount <= 0) {
      throw const AppException('El monto debe ser mayor a cero.');
    }

    await ensureClientFinancialProfile();

    final clientRef = firestore.collection('clients').doc(_clientId);
    final savingsRef = clientRef.collection('savings').doc('main');
    final operationsRef = clientRef.collection('operations').doc();
    final movementsRef = clientRef.collection('movements').doc();

    await firestore.runTransaction((transaction) async {
      final clientDoc = await transaction.get(clientRef);
      final data = clientDoc.data() ?? {};
      final currentBalance = data['totalBalance'] as num? ?? initialBalance;
      if (currentBalance < amount) {
        throw const AppException(
          'Saldo insuficiente para realizar la operación.',
        );
      }

      final newBalance = currentBalance - amount;
      transaction.update(clientRef, {
        'totalBalance': newBalance,
        'savingsBalance': newBalance,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      transaction.set(savingsRef, {
        'balance': newBalance,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      transaction.set(operationsRef, {
        'type': type,
        'amount': amount,
        'status': 'Exitosa',
        'date': _today,
        'createdAt': FieldValue.serverTimestamp(),
        ...detail,
      });
      transaction.set(movementsRef, {
        'title': type,
        'amount': amount,
        'date': _today,
        'isIncome': false,
        'createdAt': FieldValue.serverTimestamp(),
        ...detail,
      });
    });
  }
}
