// Импорт необходимых библиотек Flutter
import 'package:flutter/material.dart'; // Для создания пользовательского интерфейса
import 'package:url_launcher/url_launcher.dart'; // Для открытия веб-ссылок

// Главная функция - точка входа в приложение
void main() => runApp(const DomainBotApp());

// Основной класс приложения
class DomainBotApp extends StatelessWidget {
  const DomainBotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Domain Hunter', // Название приложения
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple, // Основной цвет темы
          brightness: Brightness.dark, // Темная тема
        ),
        useMaterial3: true, // Использовать Material Design 3
        cardTheme: CardTheme(
          elevation: 3, // Тень для карточек
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(12), // Закругленные углы карточек
          ),
        ),
      ),
      home: const DomainBotHomePage(), // Стартовый экран
      debugShowCheckedModeBanner: false, // Скрыть баннер debug
    );
  }
}

// Класс главной страницы (сохраняет состояние)
class DomainBotHomePage extends StatefulWidget {
  const DomainBotHomePage({super.key});

  @override
  _DomainBotHomePageState createState() => _DomainBotHomePageState();
}

// Состояние главной страницы
class _DomainBotHomePageState extends State<DomainBotHomePage> {
  // Список найденных доменов
  List<String> foundDomains = [];

  // Флаг показывающий идет ли поиск
  bool isSearching = false;

  // Контроллеры для полей ввода
  final TextEditingController _keywordController = TextEditingController();
  final TextEditingController _tldController =
      TextEditingController(text: 'com');

  // Списки для генерации вариантов доменов:
  final List<String> _prefixes = [
    'best',
    'top',
    'prime',
    'pro',
    'my',
    'the',
    'super',
    'mega',
    'ultra',
    'neo',
    'alpha',
    'omega',
    'gold',
    'silver',
    'vip'
  ];

  final List<String> _suffixes = [
    'shop',
    'hub',
    'online',
    'site',
    'web',
    'net',
    'store',
    'market',
    'zone',
    'tech',
    'ai',
    'io',
    'app',
    'cloud',
    'digital'
  ];

  final List<String> _popularTlds = [
    'com',
    'net',
    'org',
    'io',
    'ai',
    'co',
    'dev',
    'app',
    'xyz',
    'tech'
  ];

  // Функция поиска доменных имен
  Future<void> searchDomains() async {
    // Устанавливаем флаг поиска и очищаем предыдущие результаты
    setState(() {
      isSearching = true;
      foundDomains.clear();
    });

    // Получаем введенные пользователем данные
    final keyword = _keywordController.text.trim();
    final tld = _tldController.text.trim();

    // Проверка на пустое поле ключевого слова
    if (keyword.isEmpty) {
      setState(() => isSearching = false);
      return;
    }

    // Список для хранения сгенерированных доменов
    List<String> generatedDomains = [];

    // 1. Базовые варианты:
    // - keyword.tld (например: example.com)
    // - keyword+timestamp.tld (например: example123456.com)
    // - keyword+год.tld (например: example2023.com)
    generatedDomains.add('$keyword.$tld');
    generatedDomains
        .add('${keyword}${DateTime.now().millisecondsSinceEpoch ~/ 1000}.$tld');
    generatedDomains.add('${keyword}${DateTime.now().year}.$tld');

    // 2. Варианты с префиксами:
    // - prefixkeyword.tld (например: bestexample.com)
    // - prefix-keyword.tld (например: best-example.com)
    for (var prefix in _prefixes) {
      generatedDomains.add('$prefix$keyword.$tld');
      generatedDomains.add('$prefix-$keyword.$tld');
    }

    // 3. Варианты с суффиксами:
    // - keywordsuffix.tld (например: exampleshop.com)
    // - keyword-suffix.tld (например: example-shop.com)
    for (var suffix in _suffixes) {
      generatedDomains.add('$keyword$suffix.$tld');
      generatedDomains.add('$keyword-$suffix.$tld');
    }

    // 4. Комбинированные варианты:
    // - prefixkeywordsuffix.tld (например: bestexampleshop.com)
    for (var prefix in _prefixes) {
      for (var suffix in _suffixes) {
        generatedDomains.add('$prefix$keyword$suffix.$tld');
      }
    }

    // Имитация задержки поиска (в реальном приложении здесь будет API-запрос)
    await Future.delayed(const Duration(seconds: 1));

    // Обновляем состояние с найденными доменами
    setState(() {
      foundDomains = generatedDomains;
      isSearching = false;
    });
  }

  // Функция для открытия WHOIS информации о домене
  Future<void> _launchDomain(String domain) async {
    final url = 'https://www.whois.com/whois/$domain';
    try {
      // Проверяем возможность открыть URL
      if (await canLaunchUrl(Uri.parse(url))) {
        // Открываем URL в браузере
        await launchUrl(Uri.parse(url));
      } else {
        throw 'Не удалось открыть $url';
      }
    } catch (e) {
      // Показываем сообщение об ошибке, если виджет еще отображается
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e')),
        );
      }
    }
  }

  // Построение пользовательского интерфейса
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Верхняя панель приложения
      appBar: AppBar(
        title: const Text('Domain Hunter'),
        actions: [
          // Кнопка настроек
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Реализовать экран настроек
            },
          ),
        ],
      ),

      // Основное содержимое страницы
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Строка с полями ввода
            Row(
              children: [
                // Поле для ключевого слова (занимает 75% ширины)
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _keywordController,
                    decoration: const InputDecoration(
                      labelText: 'Ключевое слово',
                      hintText: 'Например: tech, shop, ai',
                      border: OutlineInputBorder(), // Рамка вокруг поля
                    ),
                  ),
                ),
                const SizedBox(width: 10), // Отступ между полями
                // Поле для доменной зоны (25% ширины)
                Expanded(
                  flex: 1,
                  child: TextField(
                    controller: _tldController,
                    decoration: const InputDecoration(
                      labelText: 'Зона',
                      hintText: 'com, net, io',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20), // Вертикальный отступ

            // Кнопка поиска доменов
            ElevatedButton(
              onPressed: isSearching ? null : searchDomains,
              child: isSearching
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Найти домены'),
              style: ElevatedButton.styleFrom(
                minimumSize:
                    const Size(double.infinity, 50), // Ширина на весь экран
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),

            const SizedBox(height: 20),

            // Список найденных доменов
            Expanded(
              child: ListView.builder(
                itemCount: foundDomains.length,
                itemBuilder: (context, index) {
                  return DomainCard(
                    domain: foundDomains[index],
                    onTap: () => _launchDomain(foundDomains[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // Плавающая кнопка для доступа к купленным доменам
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Реализовать экран купленных доменов
        },
        child: const Icon(Icons.shopping_cart),
        tooltip: 'Мои домены',
      ),
    );
  }
}

// Виджет карточки домена
class DomainCard extends StatelessWidget {
  final String domain; // Название домена
  final VoidCallback onTap; // Функция, вызываемая при нажатии

  const DomainCard({
    Key? key,
    required this.domain,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: onTap, // Обработчик нажатия на всю карточку
        borderRadius: BorderRadius.circular(12), // Закругленные углы
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Название домена
              Text(
                domain,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),

              // Строка с кнопками действий
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Текст-подсказка
                  const Text(
                    'Проверить доступность',
                    style: TextStyle(color: Colors.grey),
                  ),

                  // Кнопки действий
                  Row(
                    children: [
                      // Кнопка покупки
                      IconButton(
                        icon: const Icon(Icons.shopping_cart,
                            color: Colors.green),
                        onPressed: () {
                          // TODO: Реализовать покупку домена
                        },
                      ),
                      // Кнопка открытия WHOIS
                      IconButton(
                        icon: const Icon(Icons.open_in_new, color: Colors.blue),
                        onPressed: onTap,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
