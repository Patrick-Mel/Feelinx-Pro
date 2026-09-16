import os

with open('scratch_base.html', 'r', encoding='utf-8') as f:
    content = f.read()

# Add Sun/Moon quick toggle button to navbar right side
sun_moon_nav = '''
                <!-- Quick 1-click Dark/Light mode toggle button -->
                <li class="nav-item">
                    <a class="nav-link btn px-2" id="quick-theme-toggle" href="#" role="button" title="Basculez Thème Sombre / Clair (Dark/Light Mode)">
                        <i id="quick-theme-icon" class="fas fa-sun text-warning" style="font-size: 1.15rem;"></i>
                    </a>
                </li>
'''

content = content.replace('<ul class="navbar-nav ms-auto">', '<ul class="navbar-nav ms-auto">\n' + sun_moon_nav)

# Enhance language chooser button with badge and flags
old_lang_btn = '''<a class="nav-link btn" data-bs-toggle="dropdown" href="#" title="Choose language">
                            <i class="fas fa-globe" aria-hidden="true"></i>
                        </a>'''
new_lang_btn = '''<a class="nav-link btn d-flex align-items-center gap-1" data-bs-toggle="dropdown" href="#" title="Changer de langue / Select language">
                            <i class="fas fa-globe" aria-hidden="true"></i>
                            <span class="badge bg-danger text-uppercase" style="font-size: 0.75rem;">{{ LANGUAGE_CODE }}</span>
                        </a>'''

content = content.replace(old_lang_btn, new_lang_btn)

# Add custom high-contrast CSS and dark mode script
custom_head = '''
<style>
    /* Premium High-Contrast Theme Fixes for Jazzmin Admin */
    [data-bs-theme="dark"] body, [data-bs-theme="dark"] .app-wrapper, [data-bs-theme="dark"] .app-main {
        background-color: #0f172a !important;
        color: #f8fafc !important;
    }
    [data-bs-theme="dark"] .card, [data-bs-theme="dark"] .app-content-header {
        background-color: #1e293b !important;
        border-color: #334155 !important;
        color: #f8fafc !important;
    }
    [data-bs-theme="dark"] .card-header {
        background-color: #334155 !important;
        color: #f8fafc !important;
        font-weight: bold;
    }
    [data-bs-theme="dark"] a {
        color: #38bdf8 !important;
    }
    [data-bs-theme="dark"] a:hover {
        color: #7dd3fc !important;
        text-decoration: underline;
    }
    [data-bs-theme="dark"] .table {
        color: #f8fafc !important;
        border-color: #334155 !important;
    }
    [data-bs-theme="dark"] .table th {
        background-color: #1e293b !important;
        color: #f8fafc !important;
    }
    [data-bs-theme="dark"] .table td {
        background-color: #0f172a !important;
    }
    [data-bs-theme="dark"] .btn-primary {
        background-color: #ec4899 !important;
        border-color: #db2777 !important;
    }
    [data-bs-theme="dark"] .btn-info {
        background-color: #0284c7 !important;
        border-color: #0369a1 !important;
        color: #ffffff !important;
    }

    /* Light Theme Crisp Styling */
    [data-bs-theme="light"] body, [data-bs-theme="light"] .app-wrapper {
        background-color: #f1f5f9 !important;
        color: #0f172a !important;
    }
    [data-bs-theme="light"] .card {
        background-color: #ffffff !important;
        border-color: #cbd5e1 !important;
        box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05);
    }
    [data-bs-theme="light"] a {
        color: #2563eb !important;
    }
</style>
'''

content = content.replace('</head>', custom_head + '\n</head>')

custom_script = '''
<script>
    document.addEventListener('DOMContentLoaded', function() {
        var savedMode = localStorage.getItem('jazzmin-theme-mode') || 'dark';
        document.documentElement.setAttribute('data-bs-theme', savedMode);
        
        var icon = document.getElementById('quick-theme-icon');
        if (icon) {
            icon.className = savedMode === 'dark' ? 'fas fa-sun text-warning' : 'fas fa-moon text-primary';
        }

        var btn = document.getElementById('quick-theme-toggle');
        if (btn) {
            btn.addEventListener('click', function(e) {
                e.preventDefault();
                var active = document.documentElement.getAttribute('data-bs-theme') || 'light';
                var next = active === 'dark' ? 'light' : 'dark';
                document.documentElement.setAttribute('data-bs-theme', next);
                localStorage.setItem('jazzmin-theme-mode', next);
                if (icon) {
                    icon.className = next === 'dark' ? 'fas fa-sun text-warning' : 'fas fa-moon text-primary';
                }
            });
        }
    });
</script>
'''

content = content.replace('{% block extrajs %}{% endblock %}', custom_script + '\n{% block extrajs %}{% endblock %}')

os.makedirs('templates/admin', exist_ok=True)
with open('templates/admin/base.html', 'w', encoding='utf-8') as f:
    f.write(content)

print('Successfully written templates/admin/base.html with styling enhancements, size:', len(content))
