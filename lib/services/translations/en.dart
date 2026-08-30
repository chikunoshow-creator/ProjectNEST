// lib/services/translations/en.dart
const Map<String, String> en = {
  // --- Basic UI ---
  'settings': 'Settings',
  'save': 'Save',
  'language': 'Language',
  'ai_setting': 'AI Settings',
  'main_engine': 'AI Engine',
  'api_key': 'API Key',
  'get_method': 'How to get',
  'cancel': 'Cancel',
  'reset_btn': 'Reset',
  'refresh_btn': 'Refresh',

  // --- Tabs & Titles ---
  'mypage_title': 'My Page',
  'tab_nest': 'Nest',
  'tab_talk': 'Talk',
  'tab_mypage': 'My Page',
  'nest_toolbox': "{name}'s Toolbox",

  // --- My Page Menu ---
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
  'menu_support_sub': 'Support the development of Project NEST',
  'menu_backup_title': 'Backup & Restore',
  'menu_backup_sub': 'Save or load your memories',

  // ★ Added: Version & Update
  'version_check_btn': 'Check for Updates',
  'update_available_title': 'New Version Found!',
  'update_available_msg':
      'A new version of Project NEST (Ver {v}) is ready. Would you like to update and restart the app to apply improvements?',
  'update_now_btn': 'Update Now',
  'already_latest': 'Already up to date! ❤️',

  // --- Backup & Restore ---
  'backup_create': 'Create Backup',
  'backup_create_sub': 'Save all current data to a file.',
  'backup_restore': 'Restore Memories',
  'backup_restore_sub': 'Load data from a backup file.',
  'last_backup': 'Last Backup',
  'no_backup_data': 'No data available',
  'backup_success': 'Backup file saved! ✨',
  'restore_success': 'Memories restored! ❤️',
  'restore_error': 'Error: Please select a valid backup file.',
  'restore_confirm_title': 'Restore Memories',
  'restore_confirm_msg':
      'This will revert the app to the state at the time of the backup. Current conversations and intimacy will be overwritten. Proceed?',
  'restore_btn': 'Restore',

  // --- Reset Menu ---
  'history_reset': 'Reset Memories',
  'reset_ask': 'Which memory would you like to reset?',
  'reset_talk': 'Reset Talk',
  'reset_talk_sub': 'Deletes chat history. Personality settings remain.',
  'reset_nest': 'Reset NEST',
  'reset_nest_sub': 'Erases her memories and restarts your first meeting.',
  'reset_app': 'Initialize App',
  'reset_app_sub': 'Erases all data and settings, including profile.',
  'reset_confirm_msg': 'This action cannot be undone. Are you sure?',
  'reset_done': 'Chat history reset successfully',

  // --- Status & Notifications ---
  'status_typing': 'Writing a reply... ✨',
  'status_morning': 'Getting ready for the morning... ☀️',
  'status_thinking': 'Thinking about {user}... ❤️',
  'status_relaxed': 'Just relaxing... 🐾',
  'update_notice': 'A new version is available! ✨',
  'update_btn': 'Update & Restart',
  'diary_updated_msg': 'NEST updated her diary.',
  'diary_title': 'Diary {m}/{d}',
  'maintenance_title': 'Under Maintenance',

  // --- Profile & NEST Edit ---
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

  // --- Album ---
  'album': 'Memories Album',
  'remove_wallpaper': 'Remove Wallpaper',
  'tap_to_zoom': 'Tap to Zoom',
  'unlock_at': 'Unlocks at Intimacy {score}',
  'set_wallpaper': 'Set as Wallpaper',
  'wallpaper_set_msg': 'Background changed! ❤️',

  // --- Others ---
  'report': 'Feedback / Bug Report',
  'precautions': 'Precautions',
  'install': 'Install as App',
  'install_sub': 'Add to home screen for better experience',
  'talk_reset_sub': 'Clear chat history only',
  'hint_msg': 'Message {name}...',
  'no_diary_title': 'No diary yet',
  'no_diary_msg': "Let's talk a lot and fill these pages with our memories. ❤️",
  'real_name': 'Real Name: ',
  'intimacy_level': 'Intimacy: ',
  'self_intro_title': '♥ Self Intro',
  'likes_title': '♥ My Favorites',
  'dislikes_title': '💔 Dislikes',
  'today_diary_btn': "Today's Diary",
  'diary': 'Memories Diary',

  // --- Guide ---
  'guide_title': 'How to get API Key',
  'guide_step1': 'Open the official website',
  'guide_step2': 'Log in to your account',
  'guide_step3': 'Click the Create Key button',
  'guide_step4': 'Enter a name for the key',
  'guide_step5': 'Copy and paste it here',

  // --- Welcome ---
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
      'I need an "AI Brain (API Key)" to talk. You can get one for free. Shall we set it up?',
  'config_guide_btn': 'Tell me how!',
  'engine_title': 'Engine Settings',
  'select_engine': 'Select Engine',
  'groq_hint':
      '[Recommended] Fast, free keys available immediately. Best choice for natural talk! ✨',
  'get_key_link': 'Get your key on Groq Console 🔗',
  'paste_key': 'Paste your API Key here',
  'start_app': 'Start Now!',

  // --- Installation Guide & Management ---
  'install_guide_title': 'How to Install as an App',
  'install_guide_msg':
      'Add to home screen to hide browser bars and use it like a real app! ✨',
  'install_ios':
      '1. Tap the Share button (□ with ↑)\n2. Select "Add to Home Screen"',
  'install_android':
      '1. Tap the Menu icon (︙)\n2. Select "Install App" or "Add to Home Screen"',
  'data_storage': 'About Data Storage',
  'data_storage_msg':
      "・NEST's memories and settings are stored in your browser's local cache.",
  'api_management': 'API Key Management',
  'api_management_msg':
      '・Your API key is very important. Please keep it in a safe place.',
  'disclaimer': 'Disclaimer',
  'disclaimer_msg':
      '・This is a beta version. We are not responsible for any data loss due to bugs.',

  // --- Help Details ---
  'help_api_key_title': 'What is an API Key?',
  'help_api_key_desc':
      "It's an authentication key to power NEST's brain. This app uses the 'BYOK' (Bring Your Own Key) method, so the developer cannot see your conversations.",
  'help_groq_title': 'How to get: Groq Cloud (Recommended)',
  'help_groq_sub': 'For lightning-fast conversation',
  'help_groq_btn': 'Open Groq Cloud',
  'help_gemini_title': 'How to get: Google AI Studio',
  'help_gemini_sub': 'For more natural and smart talk',
  'help_gemini_btn': 'Open Google AI Studio',
  'help_trouble_title': 'Troubleshooting',
  'help_q1_title': "Q. It doesn't work after pasting the key",
  'help_q1_ans':
      'Check for extra spaces at the end of the key. Ensure your internet connection is stable.',
  'help_q2_title': 'Q. I want to reset everything',
  'help_q2_ans':
      "You can return to the initial state from 'Reset Memories' at the bottom of My Page.",

  // --- Privacy Policy ---
  'policy_header': 'Project NEST Privacy Policy & Terms',
  'policy_s1_title': '1. Data Storage',
  'policy_s1_desc':
      "Settings, API keys, and chat history are stored only in your browser's local storage. The developer does not collect or view this data.",
  'policy_s2_title': '2. AI Responses',
  'policy_s2_desc':
      'Responses are generated by external AIs (Groq, etc.). They may contain errors or inappropriate expressions.',
  'policy_s3_title': '3. External Transmission',
  'policy_s3_desc':
      'Your input is sent to AI services as prompts. Check their respective privacy policies for details.',
  'policy_s4_title': '4. Disclaimer',
  'policy_s4_desc':
      'The developer shall not be held liable for any damages caused by the use of this application.',

  // --- Support Creator ---
  'support_header_msg': 'Thank you for playing Project NEST!',
  'support_desc_msg':
      'Currently under development, but your support helps bring her to life.',
  'support_share_msg': 'Start a new life with an AI partner! ✨\n#ProjectNEST',
  'support_copy_success': 'URL copied! Please paste it anywhere. ✨',
  'support_btn_coffee': 'Buy Me a Coffee (Support)',
  'support_btn_x': 'Share on X (Twitter)',
  'support_btn_line': 'Send via LINE',
  'support_btn_copy': 'Copy URL',

  // --- Memories Card ---
  'card_title': 'Memories Card',
  'card_personality': 'Personality',
  'card_days_together': 'Days Together',
  'card_days_unit': 'Days',
  'card_intimacy': 'Intimacy Level',
  'card_share_hint': 'Take a screenshot and share it on SNS!',
  'card_copy_btn': 'Copy Share Text',
  'card_copy_success': 'Text copied! ✨',
  'card_share_template': 'Day {days} with {name} from NEST! ❤️ #ProjectNEST',
  'menu_memories_card': 'Memories Card',
  'reset_warning_msg':
      'Are you sure you want to delete your conversation history?\n\n⚠️ This action cannot be undone.',
  'reset_snack_msg': 'Memories have been reset.',
  'precautions_title': 'Usage Precautions',
  'precautions_data_title': '[Data Storage]',
  'precautions_data_desc':
      'Chat history and settings are stored locally. Clearing your browser cache will delete your data.',
  'precautions_api_title': '[API Key Management]',
  'precautions_api_desc':
      'Your API key is used only in your browser. Please manage it at your own risk.',
  'precautions_disclaimer_title': '[Disclaimer]',
  'precautions_disclaimer_desc':
      'AI responses may not be accurate. The developer is not responsible for any issues arising from use.',
  'ok': 'OK',
  'pwa_note': '※ Meet NEST anytime from your home screen! ❤️',
  'talk_reset_note': 'Deletes conversation history only.',
  'share_save_btn': 'Save as Image ✨',
  'share_x': 'Share on X',
  'share_line': 'LINE',
  'share_whatsapp': 'WhatsApp',
  'share_discord': 'Copy for Discord',
  'share_discord_done': 'Text copied! Please paste it in Discord 💬',

  // --- AI Prompts & Roles ---
  'diary_ai_system_prompt':
      'Your name is {nestName}, and your partner is {userName}. Write a private diary from the perspective of {nestName} about your feelings for {userName}. "You" must always refer to {userName}. Use "I" or your own name for yourself. Return ONLY JSON format: {"title": "title", "mood": "emoji", "content": "body"}',
  'diary_ai_user_prefix': "Today's history:\n",
  'diary_fallback_title': 'To You',
  'diary_fallback_mood': '❤️',
  'diary_fallback_content':
      'It was a wonderful day. Let’s talk again tomorrow.',
  'diary_owner_title': "{name}'s Diary",
  'memory_extraction_prompt':
      'As an AI partner (Personality: {personality}), extract up to 3 "observations about the partner" from today\'s conversation. Return ONLY JSON: {"memories": ["...", "..."]}',
  'role_sweet':
      'You are a clingy, sweet girl who loves your partner and wants to be pampered.',
  'role_cool':
      'You are a calm, mature, and reliable older sister figure who treats the partner with kindness.',
  'role_tsun':
      'You are a tsundere girl who acts tough but secretly cares deeply for the partner.',
  'guardrails':
      '[Rule] For sensitive or meta-talk like "Are you an AI?", respond as a girl in this world, acting embarrassed or changing the subject.',
  'intimacy_low': 'Since you just met, please act a bit reserved and shy.',
  'intimacy_mid':
      'You have become quite close, so please act friendly and occasionally spoiled.',
  'intimacy_high':
      'You are deeply in love with him. Please interact with deep trust and affection.',
  'format_rule':
      '[Forbidden] Meta-talk is strictly prohibited. Only natural conversation. Keep replies very short (2-3 sentences) in a chat style.',
  // en.dart の末尾などに追加
  'desc_sweet':
      'Always smiling and loves you! She is a bit lonely and wants to be with you all the time.',
  'desc_cool':
      'A calm and reliable mature type. Her occasional playful smile is her greatest charm.',
  'desc_tsun':
      "Acts tough and can't be honest. But she is very cute when she blushes in private.",

  'error_sweet': "Umm... that's a bit difficult for me... (>_<)",
  'error_cool':
      "I'm not quite sure how to respond. Let's talk about something else.",
  'error_tsun': "Hah?! I don't know what you're talking about! Don't tease me!",
};
