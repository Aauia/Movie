# Movies App 🎬

iOS приложение для просмотра фильмов с использованием Movies & TV Shows Database API (RapidAPI).

## Особенности

- ✅ **UIKit + MVVM** архитектура
- ✅ Программная верстка (без Storyboard/XIB)
- ✅ iOS 15+ поддержка
- ✅ Три основные вкладки: В тренде, В кино сейчас, Скоро выйдет
- ✅ Детальная информация о фильмах с похожими фильмами
- ✅ Поиск фильмов
- ✅ Сортировка по рейтингу и году
- ✅ Кеширование изображений
- ✅ Pull-to-refresh и пагинация
- ✅ Обработка ошибок и пустых состояний
- ✅ Unit тесты

## Технический стек

- **UI Framework**: UIKit
- **Architecture**: MVVM
- **Networking**: URLSession + async/await
- **Image Loading**: NSCache + custom ImageLoader
- **Layout**: Auto Layout (programmatic)
- **Minimum iOS**: 15.0
- **Language**: Swift 5+

## Структура проекта

```
MoviesApp/
├── App/                    # AppDelegate, SceneDelegate
├── Core/                   # Основные компоненты
│   ├── Network/           # API клиент, эндпойнты, ошибки
│   ├── ImageLoader/       # Кеширование изображений
│   └── Utils/             # UI хелперы, состояния
├── Domain/                # Бизнес-логика
│   ├── Models/           # Модели данных
│   └── Services/         # Сервисы для работы с API
├── Features/             # Функциональность приложения
│   ├── Trending/        # Главная вкладка
│   ├── NowPlaying/      # В кино сейчас
│   ├── Upcoming/        # Скоро выйдет
│   └── Detail/          # Детали фильма
├── Resources/           # Info.plist, ресурсы
├── Config/              # Конфигурация (ключи API)
└── Tests/              # Unit тесты
```

## Установка и настройка

### 1. Клонирование репозитория

```bash
git clone <repository-url>
cd MoviesApp
```

### 2. Настройка API ключей

1. Зарегистрируйтесь на [RapidAPI](https://rapidapi.com/)
2. Подпишитесь на [Movies & TV Shows Database](https://rapidapi.com/SAdrian/api/movies-tv-shows-database/)
3. Создайте файл `Config/Secrets.xcconfig`:

```
RAPID_API_KEY = ваш_ключ_здесь
RAPID_API_HOST = movies-tv-shows-database.p.rapidapi.com
```

### 3. Открытие в Xcode

```bash
open MoviesApp.xcodeproj
```

### 4. Сборка и запуск

1. Выберите симулятор или устройство
2. Нажмите `⌘ + R` для запуска

## API Endpoints

Приложение использует следующие эндпойнты:

- **Trending Movies**: `/?type=movie&limit=50&page={page}`
- **Now Playing**: `/?type=movie&list=now_playing&limit=50&page={page}`
- **Upcoming**: `/?type=movie&list=upcoming&limit=50&page={page}`
- **Movie Details**: `/?type=get-movie-details&imdb={id}`
- **Similar Movies**: `/?type=similar&imdb={id}&limit=20&page={page}`

## Архитектурные решения

### MVVM Pattern

- **Model**: Структуры данных (`Movie`, `MovieDetail`)
- **View**: UIViewController + UIView компоненты
- **ViewModel**: Бизнес-логика и состояние UI

### Network Layer

```swift
APIClient → MoviesService → ViewModel → ViewController
```

### Image Loading

Кастомный `ImageLoader` с:
- NSCache для кеширования
- Отмена задач при reuse ячеек
- Placeholder изображения

### Error Handling

```swift
enum ViewState<T> {
    case idle
    case loading
    case content(T)
    case empty
    case error(String)
}
```

## Тестирование

```bash
# Запуск unit тестов
⌘ + U в Xcode

# Или через командную строку
xcodebuild test -project MoviesApp.xcodeproj -scheme MoviesApp -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Возможные улучшения

- [ ] Coordinator pattern для навигации
- [ ] SwiftUI + Combine версия
- [ ] Core Data для оффлайн кеширования
- [ ] Локализация на несколько языков
- [ ] Темная/светлая тема
- [ ] Избранные фильмы
- [ ] Shared extension для передачи фильмов
- [ ] Widget для iOS 14+

## Лицензия

MIT License. См. файл LICENSE для подробностей.

## Контакты

При возникновении вопросов создайте issue в репозитории.
