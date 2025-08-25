Конечно! Вот полностью обновлённый README с добавленным пунктом о том, что в `APIClient` нужно изменить API ключ, **без вставки кода**:

---

# Movies App 🎬

iOS приложение для просмотра фильмов с использованием Movies & TV Shows Database API (RapidAPI).

## Особенности

* ✅ **UIKit + MVVM** архитектура
* ✅ Программная верстка (без Storyboard/XIB)
* ✅ iOS 15+ поддержка
* ✅ Три основные вкладки: В тренде, В кино сейчас, Скоро выйдет
* ✅ Детальная информация о фильмах с похожими фильмами
* ✅ Поиск фильмов
* ✅ Сортировка по рейтингу и году
* ✅ Кеширование изображений
* ✅ Pull-to-refresh и пагинация
* ✅ Обработка ошибок и пустых состояний
* ✅ Unit тесты
* ✅ YouTube трейлеры для фильмов
* ✅ Современный UI с градиентами и анимациями

## Технический стек

* **UI Framework**: UIKit
* **Architecture**: MVVM
* **Networking**: URLSession + async/await
* **Image Loading**: NSCache + custom ImageLoader с YouTube thumbnail fallback
* **Layout**: Auto Layout (programmatic)
* **Minimum iOS**: 15.0
* **Language**: Swift 5+
* **API**: Movies & TV Shows Database (RapidAPI)

## Структура проекта

```
MoviesApp/
├── App/                    # AppDelegate, SceneDelegate
├── Core/                   # Основные компоненты
│   ├── Network/           # API клиент, эндпойнты, ошибки
│   ├── ImageLoader/       # Кеширование изображений + YouTube thumbnails
│   └── Utils/             # UI хелперы, состояния, цвета
├── Domain/                # Бизнес-логика
│   ├── Models/           # Модели данных (Movie, MovieDetail)
│   └── Services/         # Сервисы для работы с API
├── Features/             # Функциональность приложения
│   ├── Trending/        # Главная вкладка с поиском
│   ├── NowPlaying/      # В кино сейчас
│   ├── Upcoming/        # Скоро выйдет
│   └── Detail/          # Детали фильма + похожие фильмы
├── Resources/           # Info.plist, ресурсы
└── Tests/                # Unit тесты
```

## Установка и настройка

### 1. Клонирование репозитория

```bash
git clone <repository-url>
cd MoviesApp
```

### 2. Настройка API ключей

1. Зарегистрируйтесь на [RapidAPI](https://rapidapi.com/).
2. Подпишитесь на [Movies & TV Shows Database](https://rapidapi.com/SAdrian/api/movies-tv-shows-database/).
3. Создайте файл `Config/Secrets.xcconfig` с вашим API ключом и хостом
4. Добавьте файл в проект и настройте **Build Settings**, чтобы Xcode подтягивал переменные.
5. **Важно:** в `APIClient`  и "ImageLoader" нужно заменить текущий API ключ на ваш, иначе приложение не сможет получать данные.

### 3. Открытие в Xcode

```bash
open MoviesApp.xcodeproj
```

### 4. Сборка и запуск

1. Выберите симулятор или устройство
2. Нажмите `⌘ + R` для запуска

## API Endpoints

Приложение использует следующие эндпойнты:

* **Trending Movies**: `get-trending-movies` с пагинацией
* **Now Playing**: `get-nowplaying-movies` с пагинацией
* **Upcoming**: `get-upcoming-movies` с пагинацией
* **Movie Details**: `get-movie-details` по IMDB ID
* **Similar Movies**: `get-similar-movies` по IMDB ID
* **Search**: `get-movies-by-title` с пагинацией

## Архитектурные решения

### MVVM Pattern

* **Model**: Структуры данных (`Movie`, `MovieDetail`)
* **View**: UIViewController + UIView компоненты
* **ViewModel**: Бизнес-логика и состояние UI

### Network Layer

APIClient → MoviesService → ViewModel → ViewController

### Image Loading

Кастомный ImageLoader с:

* NSCache для кеширования (50MB лимит)
* YouTube thumbnail fallback для постеров
* Placeholder изображения с градиентами
* Отмена задач при reuse ячеек

### Error Handling

Используется enum `ViewState` с состояниями: idle, loading, content, empty, error

### UI Features

* **Градиентные фоны** для всех экранов
* **Glass-morphism эффекты** для карточек
* **Тени и анимации** для глубины
* **Адаптивная верстка** для разных размеров экранов

## Тестирование

```bash
# Запуск unit тестов
⌘ + U в Xcode

# Или через командную строку
xcodebuild test -project MoviesApp.xcodeproj -scheme MoviesApp -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Возможные улучшения

* [ ] Coordinator pattern для навигации
* [ ] SwiftUI + Combine версия
* [ ] Core Data для оффлайн кеширования
* [ ] Локализация на несколько языков
* [ ] Темная/светлая тема
* [ ] Избранные фильмы
* [ ] Shared extension для передачи фильмов
* [ ] Widget для iOS 14+
* [ ] Push уведомления о новых фильмах
* [ ] Offline режим с кешированием

## Известные особенности

* API возвращает пустые данные для первой страницы (page 1), поэтому используется смещение +1
* Для разных вкладок используются различные смещения страниц для разнообразия контента
* YouTube трейлеры загружаются асинхронно для улучшения производительности

## Лицензия

MIT License. См. файл LICENSE для подробностей.

## Контакты

При возникновении вопросов создайте issue в репозитории.

---

Если хочешь, я могу ещё выделить пункт про **замену API ключа в `APIClient`** жирным или цветом, чтобы пользователи точно его не пропустили. Сделать так?
