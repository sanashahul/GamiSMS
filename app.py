"""
GamiSMS - Refugee Healthcare Platform
A multilingual healthcare onboarding and dashboard application
"""

from flask import Flask, render_template, request, redirect, url_for, session, jsonify, g
from functools import wraps
import json
import os

app = Flask(__name__)
app.secret_key = os.environ.get('SECRET_KEY', 'refugee-healthcare-dev-key-change-in-production')

# Supported languages
LANGUAGES = {
    'en': 'English',
    'es': 'Español',
    'ar': 'العربية',
    'fr': 'Français',
    'sw': 'Kiswahili',
    'uk': 'Українська',
    'so': 'Soomaali',
    'am': 'አማርኛ'
}

# Load translations
def load_translations():
    translations = {}
    translations_dir = os.path.join(os.path.dirname(__file__), 'translations')
    for lang in LANGUAGES.keys():
        filepath = os.path.join(translations_dir, f'{lang}.json')
        if os.path.exists(filepath):
            with open(filepath, 'r', encoding='utf-8') as f:
                translations[lang] = json.load(f)
        else:
            translations[lang] = {}
    return translations

TRANSLATIONS = {}

def get_translations():
    global TRANSLATIONS
    if not TRANSLATIONS:
        TRANSLATIONS = load_translations()
    return TRANSLATIONS

def get_locale():
    """Get the current locale from session or browser preference"""
    if 'language' in session:
        return session['language']
    return request.accept_languages.best_match(LANGUAGES.keys()) or 'en'

def translate(key, **kwargs):
    """Translate a key to the current language"""
    translations = get_translations()
    lang = get_locale()

    # Navigate nested keys (e.g., "onboarding.welcome")
    keys = key.split('.')
    value = translations.get(lang, {})

    for k in keys:
        if isinstance(value, dict):
            value = value.get(k, None)
        else:
            value = None
            break

    # Fallback to English if not found
    if value is None:
        value = translations.get('en', {})
        for k in keys:
            if isinstance(value, dict):
                value = value.get(k, key)
            else:
                value = key
                break

    # Handle string formatting
    if isinstance(value, str) and kwargs:
        try:
            value = value.format(**kwargs)
        except KeyError:
            pass

    return value if value else key

@app.before_request
def before_request():
    g.locale = get_locale()
    g.languages = LANGUAGES
    g.t = translate
    g.is_rtl = g.locale in ['ar', 'am']  # Right-to-left languages

@app.context_processor
def inject_globals():
    return {
        'locale': g.locale,
        'languages': g.languages,
        't': g.t,
        'is_rtl': g.is_rtl
    }

# Routes
@app.route('/')
def index():
    """Landing page"""
    return render_template('index.html')

@app.route('/set-language/<lang>')
def set_language(lang):
    """Set the user's preferred language"""
    if lang in LANGUAGES:
        session['language'] = lang
    return redirect(request.referrer or url_for('index'))

@app.route('/onboarding')
def onboarding():
    """Start the onboarding process"""
    session['onboarding_step'] = 1
    return redirect(url_for('onboarding_step', step=1))

@app.route('/onboarding/<int:step>')
def onboarding_step(step):
    """Display onboarding step"""
    total_steps = 6
    if step < 1 or step > total_steps:
        return redirect(url_for('onboarding_step', step=1))

    session['onboarding_step'] = step
    return render_template('onboarding.html', step=step, total_steps=total_steps)

@app.route('/onboarding/complete', methods=['POST'])
def onboarding_complete():
    """Mark onboarding as complete and save user profile"""
    data = request.form.to_dict()
    session['user_profile'] = data
    session['onboarding_completed'] = True
    return redirect(url_for('dashboard'))

@app.route('/dashboard')
def dashboard():
    """Main health dashboard"""
    user_profile = session.get('user_profile', {})
    return render_template('dashboard.html', user_profile=user_profile)

@app.route('/dashboard/health-info')
def health_info():
    """Health information and resources"""
    return render_template('health_info.html')

@app.route('/dashboard/appointments')
def appointments():
    """Appointment tracking"""
    return render_template('appointments.html')

@app.route('/dashboard/medications')
def medications():
    """Medication tracking"""
    return render_template('medications.html')

@app.route('/dashboard/emergency')
def emergency():
    """Emergency contacts and information"""
    return render_template('emergency.html')

@app.route('/dashboard/resources')
def resources():
    """Community resources and support"""
    return render_template('resources.html')

@app.route('/api/save-profile', methods=['POST'])
def save_profile():
    """Save user profile data"""
    data = request.json
    session['user_profile'] = {**session.get('user_profile', {}), **data}
    return jsonify({'success': True})

@app.route('/api/health-checkin', methods=['POST'])
def health_checkin():
    """Save daily health check-in"""
    data = request.json
    checkins = session.get('health_checkins', [])
    checkins.append(data)
    session['health_checkins'] = checkins
    return jsonify({'success': True})

if __name__ == '__main__':
    # Ensure translations directory exists
    os.makedirs('translations', exist_ok=True)
    os.makedirs('templates', exist_ok=True)
    os.makedirs('static/css', exist_ok=True)
    os.makedirs('static/js', exist_ok=True)
    os.makedirs('static/images', exist_ok=True)

    app.run(debug=True, host='0.0.0.0', port=5000)
