import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Método de Bisección',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: const MyHomePage(title: 'Método de Bisección'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _xaController = TextEditingController();
  final TextEditingController _xbController = TextEditingController();
  final TextEditingController _functionController = TextEditingController();

  List<Map<String, dynamic>> _iteraciones = [];
  List<FlSpot> _points = [];
  FlSpot? _rootPoint;

  double _minY = -10;
  double _maxY = 10;

  //esat funcion solo es para transformar la entrada a numero real
  double evaluarFuncion(String funcion, double x) {
    Parser p = Parser();
    Expression exp = p.parse(funcion);
    ContextModel cm = ContextModel();
    cm.bindVariable(Variable('x'), Number(x));
    return exp.evaluate(EvaluationType.REAL, cm);
  }

  void generarPuntos(String funcion) {
    _points.clear();
    double minY = 0;
    double maxY = 10;

    for (double x = -10; x <= 10; x += 1) {
      double y = evaluarFuncion(funcion, x);
      _points.add(FlSpot(x, y));

      if (y < minY) minY = y;
      if (y > maxY) maxY = y;
    }

    setState(() {
      _minY = minY - 5;
      _maxY = maxY + 5;
    });
  }

  void biseccion(String funcion, double xa, double xb, double error) {
    _iteraciones.clear();
    double xm, fxa, fxb, fxm, errorAprox;
    int iteraciones = 0;
    double previoXm = 0;

    do {
      iteraciones++;
      xm = (xa + xb) / 2;
      fxa = evaluarFuncion(funcion, xa);
      fxb = evaluarFuncion(funcion, xb);
      fxm = evaluarFuncion(funcion, xm);

      //validar entrada pa q este bn
      try {
        evaluarFuncion(funcion, 0);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'La función ingresada no es válida. Por favor, revise el formato.',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      errorAprox = (iteraciones > 1) ? ((xm - previoXm) / xm).abs() * 100 : 0;
      previoXm = xm;

      _iteraciones.add({
        'i': iteraciones,
        'xa': xa,
        'xb': xb,
        'xM': xm,
        'fxM': fxm,
        'error': errorAprox,
      });

      //asi esta en la formula
      if (fxa * fxm < 0) {
        xb = xm;
      } else if (fxa * fxm > 0) {
        xa = xm;
      }
    } while ((xb - xa).abs() > error);

    //variable para mostrar en grafica
    _rootPoint = FlSpot(xm, 0);
  }

  void _calcularBiseccion() {
    final double xa = double.tryParse(_xaController.text) ?? 0.0;
    final double xb = double.tryParse(_xbController.text) ?? 0.0;
    final String funcion = _functionController.text;
    const double error = 0.00001;

    setState(() {
      generarPuntos(funcion);
      biseccion(funcion, xa, xb, error);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Entrada de datos
              TextField(
                controller: _functionController,
                decoration: const InputDecoration(
                  labelText: 'Ingrese la función (e.g., x^3 - 4*x - 9)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _xaController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Ingrese Xa',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _xbController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Ingrese Xb',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _calcularBiseccion,
                child: const Text('Calcular Bisección'),
              ),
              const SizedBox(height: 20),

              // Tabla con resultados
              _iteraciones.isNotEmpty
                  ? SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('i')),
                          DataColumn(label: Text('xa')),
                          DataColumn(label: Text('xb')),
                          DataColumn(label: Text('xM')),
                          DataColumn(label: Text('F(xM)')),
                          DataColumn(label: Text('Error (%)')),
                        ],
                        rows: _iteraciones
                            .map(
                              (iteracion) => DataRow(
                                cells: [
                                  DataCell(Text('${iteracion['i']}')),
                                  DataCell(Text('${iteracion['xa']}')),
                                  DataCell(Text('${iteracion['xb']}')),
                                  DataCell(Text('${iteracion['xM']}')),
                                  DataCell(Text('${iteracion['fxM']}')),
                                  DataCell(Text(
                                      '${iteracion['error'].toStringAsFixed(6)}')),
                                ],
                              ),
                            )
                            .toList(),
                      ),
                    )
                  : const Center(
                      child: Text('No hay resultados aún.'),
                    ),
              const SizedBox(height: 20),

              // Texto sobre la gráfica
              const Text(
                'Gráfica del resultado',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Tip: Presione en la gráfica para ver los puntos y el valor de la raíz.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),

              const SizedBox(height: 10),
              // Gráfica de la función
              Container(
                height: 400,
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: true),
                    titlesData: FlTitlesData(show: true),
                    borderData: FlBorderData(show: true),
                    minX: -10,
                    maxX: 10,
                    minY: _minY,
                    maxY: _maxY,
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        tooltipRoundedRadius: 8,
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((LineBarSpot touchedSpot) {
                            const textStyle = TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            );
                            if (touchedSpot.x == _rootPoint?.x) {
                              return LineTooltipItem(
                                'x raíz: ${touchedSpot.x.toStringAsFixed(2)}\n'
                                'y raíz: ${touchedSpot.y.toStringAsFixed(2)}',
                                const TextStyle(
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              );
                            }
                            return LineTooltipItem(
                              'x: ${touchedSpot.x.toStringAsFixed(2)}\n'
                              'y: ${touchedSpot.y.toStringAsFixed(2)}',
                              textStyle,
                            );
                          }).toList();
                        },
                      ),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: _points,
                        isCurved: true,
                        color: Colors.deepPurple,
                        barWidth: 2,
                        belowBarData: BarAreaData(show: false),
                      ),
                      if (_rootPoint != null)
                        LineChartBarData(
                          spots: [_rootPoint!],
                          isCurved: false,
                          color: Colors.red,
                          dotData: const FlDotData(show: true),
                          barWidth: 4,
                        ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
