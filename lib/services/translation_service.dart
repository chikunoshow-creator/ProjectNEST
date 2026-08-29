class T {
  static String get(String key, String lang) {
    final Map<String, Map<String, String>> localizedValues = {
      'ja': {
        // --- 基本UI ---
        'settings': '設定',
        'save': '保存する',
        'language': '言語 / Language',
        'ai_setting': 'AIシステム設定',
        'main_engine': 'メインエンジンの選択',
        'api_key': 'API Key',
        'get_method': '取得方法',
        'cancel': 'キャンセル',
        'reset_btn': 'リセット',
        'refresh_btn': '再読み込み',

        // --- タブ・タイトル ---
        'mypage_title': 'My Page',
        'tab_nest': 'Nest',
        'tab_talk': 'トーク',
        'tab_mypage': 'My Page',
        'nest_toolbox': '{name}の道具箱',

        // --- My Pageメニュー ---
        'menu_profile_title': 'プロフィール編集',
        'menu_profile_sub': 'あなたの名前、誕生日、好きなもの',
        'menu_nest_title': 'NESTの設定',
        'menu_nest_sub': '彼女の呼び名やニックネーム',
        'menu_ai_title': 'AIシステム設定',
        'menu_ai_sub': 'AIエンジンの選択とAPIキー設定',
        'menu_help_title': 'ヘルプ＆ガイド',
        'menu_help_sub': '困ったときや使い方はこちら',
        'menu_policy_title': '利用規約 ＆ ポリシー',
        'menu_policy_sub': '安心してご利用いただくために',
        'menu_support_title': '開発者を応援',
        'menu_support_sub': 'Project NESTの継続開発をサポート',

        'menu_backup_title': 'バックアップと復元',
        'menu_backup_sub': '大切なデータの保存・読み込み',
        'backup_create': 'バックアップを作成',
        'backup_create_sub': '現在の全データをファイルに保存します。',
        'backup_restore': '思い出を復元',
        'backup_restore_sub': 'ファイルからデータを読み込みます。',
        'last_backup': '前回のバックアップ',
        'no_backup_data': 'データがありません',
        'backup_success': 'バックアップファイルを保存したよ ✨',
        'restore_success': '思い出を復元したよ ❤️',
        'restore_error': 'エラー：正しいバックアップファイルを選んでね。',
        'restore_confirm_title': '思い出の復元',
        'restore_confirm_msg':
            '前回のバックアップ時点の状態に戻すよ。\n今の会話や親密度は上書きされちゃうけど、本当にいい？',
        'restore_btn': '復元する',

        // --- リセットメニュー ---
        'history_reset': '思い出リセット',
        'reset_ask': 'どの思い出をリセットしますか？',
        'reset_talk': 'トークをリセット',
        'reset_talk_sub': '会話履歴を削除します。性格設定は残ります。',
        'reset_nest': 'NESTをリセット',
        'reset_nest_sub': '彼女の記憶を削除し、出会い直します。',
        'reset_app': 'アプリを初期化',
        'reset_app_sub': 'プロフィールや設定を含む全てのデータを消去します。',
        'reset_confirm_msg': 'この操作は取り消せません。本当によろしいですか？',
        'reset_done': '会話履歴をリセットしました',

        // --- ステータス・通知 ---
        'status_typing': 'お返事書いてるよ！ ✨',
        'status_morning': '朝の準備をしてるよ ☀️',
        'status_thinking': '{user}のこと考えてたよ ❤️',
        'status_relaxed': 'のんびりしてるよ 🐾',
        'update_notice': '新しいバージョンが届いています！✨',
        'update_btn': '更新して再起動',
        'diary_updated_msg': 'NESTが日記を更新しました。',
        'diary_title': '{m}月{d}日の日記',
        'maintenance_title': '緊急メンテナンス中',

        // --- プロフィール編集 / NEST設定 ---
        'edit_profile': 'プロフィールの編集',
        'user_name': 'あなたのお名前',
        'user_birthday': '誕生日',
        'user_fav_food': '好きな食べ物',
        'user_job': '仕事 / 趣味',
        'save_complete': '設定を保存したよ！',
        'edit_nest': 'NESTの設定',
        'nest_name_label': '彼女の名前',
        'nickname_label': 'あなたの呼び方',
        'personality_label': '性格',

        // --- アルバム ---
        'album': '思い出アルバム',
        'remove_wallpaper': '壁紙を外す',
        'tap_to_zoom': 'タップで拡大',
        'unlock_at': '親密度 {score} で解放',
        'set_wallpaper': '壁紙に設定',
        'wallpaper_set_msg': '背景を変更したよ！❤️',

        // --- その他 ---
        'report': 'ご意見・バグ報告',
        'precautions': 'ご利用時の注意事項',
        'install': 'アプリとしてインストール',
        'install_sub': 'ホーム画面に追加して便利に使う', 'talk_reset_sub': '会話履歴のみを消去します',
        'hint_msg': '{name}にメッセージを送る...', 'no_diary_title': 'まだ日記がありません',
        'no_diary_msg': 'たくさんお話しして、二人の思い出を綴っていこうね。❤️',
        'real_name': '本名: ',
        'intimacy_level': '親密度: ',
        'self_intro_title': '♥ 自己紹介',
        'likes_title': '♥ 好きなもの',
        'dislikes_title': '💔 苦手なもの',
        'today_diary_btn': '今日の日記',
        'diary': '思い出日記帳',

        // --- ガイド ---
        'guide_title': 'APIキーの取得方法',
        'guide_step1': '公式サイトを開く',
        'guide_step2': 'ログインする',
        'guide_step3': 'キー作成ボタン',
        'guide_step4': '名前を入力',
        'guide_step5': 'コピーして貼り付け',

        // --- Welcome (初回セットアップ) ---
        'welcome_title': 'はじめまして！',
        'welcome_msg': '私はNEST。今日からあなたのパートナーになるAIです。二人の新しい生活を始めましょう！',
        'next': '次へ',
        'your_name_ask': 'あなたのことを教えて？',
        'name_label': 'お名前',
        'name_hint': '未入力なら「あなた」になるよ',
        'name_note': '※名前はMy Pageからいつでも変えられるから安心してね！', 'decide': '決定',
        'p_title': '私の性格を選んでね',
        'p_sweet': '甘えん坊',
        'p_cool': 'クールなお姉さん',
        'p_tsun': 'ツンデレ',
        'p_finish': 'これでお願い！',
        'config_title': '最後の大切な設定だよ',
        'config_msg': '私が喋るためには「AIの脳（APIキー）」が必要なの。無料で取得できるから一緒に設定しよう？',
        'config_guide_btn': 'やり方を教えて！',
        'engine_title': 'エンジンの設定',
        'select_engine': 'エンジンを選択',
        'groq_hint': '【推奨】無料でキーが即発行でき、人間の呼吸に近い速度で会話できます。迷ったらこれ！✨',
        'ollama_hint': '自分のPC内でAIを動かすため完全無料ですが、設定が非常に難解です。🏠',
        'gemini_warning': '※Google Geminiは現在、新規利用を制限しています。より高速なGroqを強く推奨します。',
        'get_method_full': '取得方法を日本語で見る',
        'get_key_link': 'Groq Consoleでキーを取得する 🔗',
        'paste_key': 'API Key を貼り付けてね',
        'start_app': 'はじめる！',

        // --- 注意事項ダイアログ等 ---
        'install_guide_title': 'アプリとして使う方法',
        'install_guide_msg': 'ホーム画面に追加すると、ブラウザの枠が消えて、本物のアプリのように使えます！ ✨',
        'install_ios': '1. 画面下の「共有ボタン（□に↑）」を押す\n2. 「ホーム画面に追加」を選択',
        'install_android':
            '1. 右上の「︙（メニュー）」を押す\n2. 「アプリをインストール」または「ホーム画面に追加」を選択',
        'data_storage': 'データの保存について',
        'data_storage_msg': '・NESTの記憶や設定はブラウザの「キャッシュ」に保存されています。',
        'api_management': 'APIキーの管理について',
        'api_management_msg': '・設定したAPIキーは非常に大切なものです。メモしておいてね。',
        'disclaimer': '免責事項',
        'disclaimer_msg': '・当アプリは開発中のβ版です。不具合等によるデータ消失の責任は負いかねます。',

        // --- help詳細 ---
        'help_api_key_title': 'APIキーとは？',
        'help_api_key_desc':
            'NESTの「脳」を動かすための認証鍵です。開発者があなたの会話を覗き見ることができないよう、自分専用の鍵を使用する「BYOK方式」を採用しています。',
        'help_groq_title': '取得手順：Groq Cloud (推奨)',
        'help_groq_sub': '爆速で喋らせたいならこちら',
        'help_groq_btn': 'Groq Cloudを開く',
        'help_gemini_title': '取得手順：Google AI Studio',
        'help_gemini_sub': 'より自然で賢い会話をしたいなら',
        'help_gemini_btn': 'Google AI Studioを開く',
        'help_trouble_title': '困ったときは',
        'help_q1_title': 'Q. キーを貼ったのに動きません',
        'help_q1_ans':
            'キーの最後に余計な空白が入っていないか確認してください。また、インターネット接続が安定しているか確認してください。',
        'help_q2_title': 'Q. 完全にリセットしたいです',
        'help_q2_ans': 'マイページの最下部にある「思い出リセット」から、初期状態に戻すことができます。',

        // --- ポリシー ---
        'policy_header': 'Project NEST プライバシーポリシー ＆ 利用規約',
        'policy_s1_title': '1. データの保存について',
        'policy_s1_desc':
            '本アプリで入力された名前、誕生日、好きなもの、およびAPIキー、会話履歴は、すべてお客様のブラウザのローカルストレージ（LocalStorage）にのみ保存されます。開発者がこれらのデータを取得・閲覧することはありません。',
        'policy_s2_title': '2. AIによる回答について',
        'policy_s2_desc':
            '本アプリの回答は、お客様が提供する外部AI（Groq等）によって生成されます。AIの回答には誤りや不適切な表現が含まれる可能性がありますが、開発者はその内容について責任を負いません。',
        'policy_s3_title': '3. 外部サービスへの送信',
        'policy_s3_desc':
            '会話の生成中、プロンプトとして入力内容が各AIサービス（Groq等）へ送信されます。各サービス側でのデータ取り扱いについては、それぞれのプライバシーポリシーをご確認ください。',
        'policy_s4_title': '4. 免責事項',
        'policy_s4_desc': '本アプリの利用によって生じた損害について、開発者は一切の責任を負いません。',

        // --- 開発者応援 ---
        'support_header_msg': 'Project NESTを遊んでくれてありがとう！',
        'support_desc_msg': '現在はまだ開発の途中ですが、あなたの応援が、彼女たちに新しい命を吹き込む力になります。',
        'support_share_msg': 'AIパートナーとの新しい生活を始めよう！✨\n#ProjectNEST',
        'support_copy_success': 'URLをコピーしました！どこでも貼り付けてね。✨',
        'support_btn_coffee': 'Buy Me a Coffee（開発支援）',
        'support_btn_x': 'X (Twitter)でシェアして応援',
        'support_btn_line': 'LINEで送る',
        'support_btn_copy': 'URLをコピー',

        // 思い出カード
        'card_title': '思い出カード',
        'card_personality': '性格',
        'card_days_together': '出会ってから',
        'card_days_unit': '日',
        'card_intimacy': '現在の親密度',
        'card_share_hint': 'スクリーンショットを撮ってSNSでシェアしてね！',
        'card_copy_btn': '共有用テキストをコピー',
        'card_copy_success': 'テキストをコピーしたよ ✨',
        'card_share_template': 'NESTの{name}と出会って{days}日目！ ❤️ #ProjectNEST',
        'menu_memories_card': '思い出カード', // ドロワー用
        // ドロワーリセットメッセージ
        'reset_warning_msg':
            '今まで積み上げてきた思い出（会話履歴）を消去するよ。\n\n⚠️ この操作は二度と戻せないけど、本当にいい？',
        'reset_snack_msg': '思い出をリセットしました。',

        // jaセクションへ追加
        'precautions_title': 'ご利用時の注意事項',
        'precautions_data_title': '【データの保存について】',
        'precautions_data_desc':
            '会話履歴や設定はブラウザのローカルストレージにのみ保存されます。ブラウザのキャッシュを削除するとデータも消えるので注意してね。',
        'precautions_api_title': '【APIキーの管理について】',
        'precautions_api_desc':
            'APIキーはあなたのブラウザ内でのみ使用され、外部サーバーに送信されることはありません。自己責任での管理をお願いします。',
        'precautions_disclaimer_title': '【免責事項】',
        'precautions_disclaimer_desc':
            'AIの回答は必ずしも正確ではありません。NESTとの会話によって生じた不利益について、開発者は一切の責任を負いかねます。',
        'ok': '了解',

        // jaセクションへ追加
        'pwa_note': '※ホーム画面からいつでもNESTに会えるようになります ❤️',
        'talk_reset_note': '会話履歴のみ消去します。',

        // 思い出カードシェア
        'share_save_btn': '思い出を画像として保存 ✨',
        'share_x': 'Xでシェア',
        'share_line': 'LINEで送る',
        'share_whatsapp': 'WhatsApp',
        'share_discord': 'Discordにコピー',
        'share_discord_done': '共有用テキストをコピーしたよ！Discordに貼ってね 💬',
      },
      'en': {
        // --- 基本UI ---
        'settings': 'Settings',
        'save': 'Save',
        'language': 'Language',
        'ai_setting': 'AI Settings',
        'main_engine': 'Select Engine',
        'api_key': 'API Key',
        'get_method': 'How to get',
        'cancel': 'Cancel',
        'reset_btn': 'Reset',
        'refresh_btn': 'Refresh',

        // --- タブ・タイトル ---
        'mypage_title': 'My Page',
        'tab_nest': 'Nest',
        'tab_talk': 'Talk',
        'tab_mypage': 'My Page',
        'nest_toolbox': "{name}'s Toolbox",

        // --- My Pageメニュー ---
        'menu_profile_title': 'Edit Profile',
        'menu_profile_sub': 'Your name, birthday, and favorites',
        'menu_nest_title': 'NEST Settings',
        'menu_nest_sub': 'Her name and nicknames',
        'menu_ai_title': 'AI System Settings',
        'menu_ai_sub': 'Select AI engine and set API keys',
        'menu_help_title': 'Help & Guide',
        'menu_help_sub': 'FAQs and How to use',
        'menu_policy_title': 'Terms & Policy',
        'menu_policy_sub': 'For your safety and privacy',
        'menu_support_title': 'Support Creator',
        'menu_support_sub': 'Support the development',

        'menu_backup_title': 'Backup & Restore',
        'menu_backup_sub': 'Save or load your data',
        'backup_create': 'Create Backup',
        'backup_create_sub': 'Save all data to a file.',
        'backup_restore': 'Restore Memories',
        'backup_restore_sub': 'Load data from a backup file.',
        'last_backup': 'Last Backup',
        'no_backup_data': 'No data',
        'backup_success': 'Backup file saved! ✨',
        'restore_success': 'Memories restored! ❤️',
        'restore_error': 'Error: Please select a valid backup file.',
        'restore_confirm_title': 'Restore Memories',
        'restore_confirm_msg':
            'This will overwrite your current progress with the backup data. Are you sure?',
        'restore_btn': 'Restore',

        // --- リセットメニュー ---
        'history_reset': 'Reset Memories',
        'reset_ask': 'Which memory to reset?',
        'reset_talk': 'Reset Talk',
        'reset_talk_sub': 'Clear chat history. Settings remain.',
        'reset_nest': 'Reset NEST',
        'reset_nest_sub': 'Clear her memory and restart.',
        'reset_app': 'Initialize App',
        'reset_app_sub': 'Erase all data and settings.',
        'reset_confirm_msg': 'This action cannot be undone. Are you sure?',
        'reset_done': 'Chat history reset',

        // --- ステータス・通知 ---
        'status_typing': 'Typing... ✨', 'status_morning': 'Getting ready... ☀️',
        'status_thinking': 'Thinking about {user}... ❤️',
        'status_relaxed': 'Just relaxing... 🐾',
        'update_notice': 'New version available! ✨',
        'update_btn': 'Update & Restart',
        'diary_updated_msg': 'NEST updated her diary.',
        'diary_title': 'Diary {m}/{d}',
        'maintenance_title': 'Under Maintenance',

        // --- プロフィール編集 / NEST設定 ---
        'edit_profile': 'Edit Profile',
        'user_name': 'Your Name',
        'user_birthday': 'Birthday',
        'user_fav_food': 'Favorite Food',
        'user_job': 'Job / Hobby',
        'save_complete': 'Settings saved!',
        'edit_nest': 'NEST Settings',
        'nest_name_label': 'Her Name',
        'nickname_label': 'How she calls you',
        'personality_label': 'Personality',

        // --- アルバム ---
        'album': 'Memories',
        'remove_wallpaper': 'Remove Wallpaper',
        'tap_to_zoom': 'Tap to Zoom',
        'unlock_at': 'Unlocks at Intimacy {score}',
        'set_wallpaper': 'Set as Wallpaper',
        'wallpaper_set_msg': 'Background changed! ❤️',

        // --- その他 ---
        'report': 'Feedback',
        'precautions': 'Precautions',
        'install': 'Install App',
        'install_sub': 'Add to home screen',
        'talk_reset_sub': 'Clear chat history only',
        'hint_msg': 'Message {name}...', 'no_diary_title': 'No diary yet',
        'no_diary_msg': "Let's talk and create some memories. ❤️",
        'real_name': 'Real Name: ',
        'intimacy_level': 'Intimacy: ',
        'self_intro_title': '♥ Self Intro',
        'likes_title': '♥ My Favorites',
        'dislikes_title': '💔 Dislikes',
        'today_diary_btn': "Today's Diary",
        'diary': 'Memories Diary',

        // --- ガイド ---
        'guide_title': 'How to get API Key',
        'guide_step1': 'Open Website',
        'guide_step2': 'Login',
        'guide_step3': 'Create Key',
        'guide_step4': 'Name it',
        'guide_step5': 'Copy & Paste',

        // --- Welcome (初回セットアップ) ---
        'welcome_title': 'Nice to meet you!',
        'welcome_msg':
            "I'm NEST, an AI who will be your partner from today. Let's start our new life together!",
        'next': 'Next',
        'your_name_ask': 'Tell me about yourself',
        'name_label': 'Your Name',
        'name_hint': 'Default is "Guest"',
        'name_note': 'Note: You can change your name anytime from My Page!',
        'decide': 'Confirm',
        'p_title': 'Choose my personality',
        'p_sweet': 'Sweet',
        'p_cool': 'Mature',
        'p_tsun': 'Tsundere',
        'p_finish': 'Perfect!',
        'config_title': 'One last thing',
        'config_msg':
            'I need an "AI Brain (API Key)" to talk. It\'s free and easy to get. Shall we set it up?',
        'config_guide_btn': 'Tell me how!',
        'engine_title': 'Engine Settings',
        'select_engine': 'Select AI Engine',
        'groq_hint':
            '[Recommended] Free keys, lightning fast. Best choice for everyone! ✨',
        'ollama_hint': 'For advanced users. Runs AI on your own PC. 🏠',
        'gemini_warning':
            'Note: Google Gemini is currently restricted. We recommend Groq.',
        'get_method_full': 'How to get (Guide)',
        'get_key_link': 'Get your key on Groq Console 🔗',
        'paste_key': 'Paste your API Key here',
        'start_app': 'Start Now!',

        // --- その他注意事項等 ---
        'install_guide_title': 'How to Install',
        'install_guide_msg':
            'Add to home screen to use it like a real app without browser bars! ✨',
        'install_ios':
            '1. Tap the Share button\n2. Select "Add to Home Screen"',
        'install_android': '1. Tap the Menu icon\n2. Select "Install App"',
        'data_storage': 'Data Storage',
        'data_storage_msg':
            'Settings are stored locally in your browser cache.',
        'api_management': 'API Keys',
        'api_management_msg':
            'Your API keys are important. Please back them up.',
        'disclaimer': 'Disclaimer',
        'disclaimer_msg': 'This is a beta version. Use at your own risk.',

        // --- help詳細 ---
        'help_api_key_title': 'What is an API Key?',
        'help_api_key_desc':
            "It's an authentication key to power NEST's brain. This app uses the 'BYOK' method, so the developer cannot see your conversations.",
        'help_groq_title': 'How to get: Groq (Recommended)',
        'help_groq_sub': 'For lightning-fast conversation',
        'help_groq_btn': 'Open Groq Cloud',
        'help_gemini_title': 'How to get: Google AI Studio',
        'help_gemini_sub': 'For natural and smart talk',
        'help_gemini_btn': 'Open Google AI Studio',
        'help_trouble_title': 'Troubleshooting',
        'help_q1_title': "Q. It doesn't work after pasting",
        'help_q1_ans':
            'Check for extra spaces at the end of the key. Ensure your internet connection is stable.',
        'help_q2_title': 'Q. I want to reset everything',
        'help_q2_ans':
            "You can return to initial state from 'Reset Memories' at the bottom of My Page.",

        // --- ポリシー ---
        'policy_header': 'Project NEST Privacy Policy & Terms of Service',
        'policy_s1_title': '1. Data Storage',
        'policy_s1_desc':
            "Names, birthdays, favorites, API keys, and chat history entered in this app are stored only in your browser's local storage (LocalStorage). The developer does not collect or view this data.",
        'policy_s2_title': '2. AI Generated Responses',
        'policy_s2_desc':
            "Responses are generated by external AIs (Groq, etc.) provided by you. AI responses may contain errors, and the developer takes no responsibility for the content.",
        'policy_s3_title': '3. Transmission to External Services',
        'policy_s3_desc':
            "Your input is sent to AI services (Groq, etc.) as prompts. Please check their respective privacy policies for data handling.",
        'policy_s4_title': '4. Disclaimer',
        'policy_s4_desc':
            "The developer shall not be held liable for any damages caused by the use of this application.",

        // --- 開発者応援 ---
        'support_header_msg': 'Thank you for playing Project NEST!',
        'support_desc_msg':
            'Currently under development, but your support helps bring her to life.',
        'support_share_msg':
            'Start a new life with an AI partner! ✨\n#ProjectNEST',
        'support_copy_success': 'URL copied! Please paste it anywhere. ✨',
        'support_btn_coffee': 'Buy Me a Coffee (Support)',
        'support_btn_x': 'Share on X (Twitter)',
        'support_btn_line': 'Send via LINE',
        'support_btn_copy': 'Copy URL',

        // 思い出カード
        'menu_memories_card': 'Memories Card',
        'card_title': 'Memories Card',
        'card_personality': 'Personality',
        'card_days_together': 'Days Together',
        'card_days_unit': 'Days',
        'card_intimacy': 'Intimacy Level',
        'card_share_hint': 'Take a screenshot and share on SNS!',
        'card_copy_btn': 'Copy Share Text',
        'card_copy_success': 'Text copied! ✨',
        'card_share_template':
            'Meeting {name} from NEST, Day {days}! ❤️ #ProjectNEST',

        // ドロワーリセットメッセージ
        'reset_warning_msg':
            'Are you sure you want to delete your conversation history?\n\n⚠️ This operation cannot be undone.',
        'reset_snack_msg': 'History has been reset.',

        // enセクションへ追加
        'precautions_title': 'Usage Precautions',
        'precautions_data_title': '[Data Storage]',
        'precautions_data_desc':
            'Data is stored only in your browser. Clearing cache will delete your data.',
        'precautions_api_title': '[API Key Management]',
        'precautions_api_desc':
            'Your API key is used only within the browser. Please manage it at your own risk.',
        'precautions_disclaimer_title': '[Disclaimers]',
        'precautions_disclaimer_desc':
            'AI responses may not be accurate. The developer is not responsible for any issues arising from use.',
        'ok': 'OK',

        // enセクションへ追加
        'pwa_note': 'Meet NEST anytime from your home screen! ❤️',
        'talk_reset_note': 'Conversation history only.',

        // 思い出カードシェア
        'share_save_btn': 'Save as Image ✨',
        'share_x': 'Share on X',
        'share_line': 'LINE',
        'share_whatsapp': 'WhatsApp',
        'share_discord': 'Copy for Discord',
        'share_discord_done': 'Text copied! Please paste it in Discord 💬',
      },
    };

    return localizedValues[lang]?[key] ?? key;
  }
}
