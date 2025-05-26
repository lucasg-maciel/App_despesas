import 'package:app_despesas/models/transaction.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'transaction_list.dart';
class TelaResumoSemanal extends StatelessWidget {
  final List<Transaction> transactions;
  const TelaResumoSemanal(this.transactions, {super.key});
  
  Map<String, List<Transaction>> get _transactionsBysemana {
  Map<String, List<Transaction>> transactionsSemana = {};
    
    for (var transaction in transactions) {
      int semana = _getsemana(transaction.date);
      String mes = DateFormat('MMMM yyyy').format(transaction.date);
      String chave = 'Semana $semana - $mes';
      
      if (transactionsSemana[chave] == null) {
        transactionsSemana[chave] = [];
      }

      transactionsSemana[chave]!.add(transaction);
    }
    return transactionsSemana;
  }

    int _getsemana(DateTime date) {
    DateTime primeiroDiaDoMes = DateTime(date.year, date.month, 1);
    
    int dia = date.day;
    
    int semana = ((dia + primeiroDiaDoMes.weekday - 2) / 7).floor() + 1;
    
    return semana;
  }

    double getTotalSemana(List<Transaction> weekTransactions) {
    return weekTransactions.fold(0.0, (sum, transaction) => sum + transaction.value);
  }

    String _getWeekDateRange(int semana, DateTime date) {
    
    DateTime primeiroDiaDoMes = DateTime(date.year, date.month, 1);

    int primeiraSegundaOffset = (8 - primeiroDiaDoMes.weekday) % 7;
    DateTime primeiraSegunda = primeiroDiaDoMes.add(Duration(days: primeiraSegundaOffset));

    if (primeiroDiaDoMes.weekday <= 1) {
      primeiraSegunda = primeiroDiaDoMes;
    } else {
    primeiraSegunda = primeiroDiaDoMes.subtract(Duration(days: primeiroDiaDoMes.weekday - 1));
    }

    int daysToAdd = (semana - 1) * 7;
    DateTime comecoSemana = primeiraSegunda.add(Duration(days: daysToAdd));
    DateTime fimSemana = comecoSemana.add(Duration(days: 6));

    DateTime ultimoDiaDoMes = DateTime(date.year, date.month + 1, 1);
    if (fimSemana.isAfter(ultimoDiaDoMes)) {
    fimSemana = ultimoDiaDoMes;
    }

    return '${DateFormat('dd/MM').format(comecoSemana)} - ${DateFormat('dd/MM').format(fimSemana)}';
  }




  @override
  Widget build(BuildContext context) {
    final weeklyData = _transactionsBysemana;
    final sortedEntries = weeklyData.entries.toList()..sort((a, b) {
        int semanaA = int.parse(a.key.split(' ')[1]);
        int semanaB = int.parse(b.key.split(' ')[1]);
        
        DateTime dateA = a.value.first.date;
        DateTime dateB = b.value.first.date;
        
        if (dateA.year != dateB.year) {
          return dateB.year.compareTo(dateA.year);
        }
        if (dateA.month != dateB.month) {
          return dateB.month.compareTo(dateA.month);
        }
      
        return semanaB.compareTo(semanaA); 
      });
      
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resumo Semanal'),
      ),
      body: weeklyData.isEmpty
          ? const Center(
              child: Text(
                'Nenhuma transação encontrada',
                style: TextStyle(fontSize: 18),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: weeklyData.length,
                    itemBuilder: (context, index) {
                      String chave = sortedEntries[index].key;
                      List<Transaction> weekTransactions = weeklyData[chave]!;
                      double weekTotal = getTotalSemana(weekTransactions);
                      int semana = int.parse(chave.split(' ')[1]);
                      String dateRange = _getWeekDateRange(semana, weekTransactions.first.date);
                      
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ExpansionTile(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      chave,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    if (dateRange.isNotEmpty)
                                      Text(
                                        dateRange,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    Text(
                                    '${weekTransactions.length} transações',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.purple,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'R\$ ${weekTotal.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          children: [
                            Container(
                              height: 175,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: TransactionList(weekTransactions, (id) {
                              }),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                ],
      ),
    );
  }
}
