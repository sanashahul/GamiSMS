/**
 * Refugee Healthcare Platform - Main JavaScript
 */

// Language change handler
function changeLanguage(lang) {
    window.location.href = `/set-language/${lang}`;
}

// Mobile menu toggle
function toggleMobileMenu() {
    const menu = document.getElementById('mobile-menu');
    menu.classList.toggle('active');
}

// Close mobile menu when clicking outside
document.addEventListener('click', function(e) {
    const menu = document.getElementById('mobile-menu');
    const btn = document.querySelector('.mobile-menu-btn');

    if (menu && !menu.contains(e.target) && !btn.contains(e.target)) {
        menu.classList.remove('active');
    }
});

// Smooth scroll for anchor links
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function(e) {
        e.preventDefault();
        const target = document.querySelector(this.getAttribute('href'));
        if (target) {
            target.scrollIntoView({
                behavior: 'smooth',
                block: 'start'
            });
        }
    });
});

// Form validation helper
function validateForm(form) {
    const required = form.querySelectorAll('[required]');
    let isValid = true;

    required.forEach(field => {
        if (!field.value.trim()) {
            isValid = false;
            field.classList.add('error');
        } else {
            field.classList.remove('error');
        }
    });

    return isValid;
}

// Local storage helpers
const Storage = {
    get(key) {
        try {
            return JSON.parse(localStorage.getItem(key));
        } catch {
            return null;
        }
    },

    set(key, value) {
        try {
            localStorage.setItem(key, JSON.stringify(value));
            return true;
        } catch {
            return false;
        }
    },

    remove(key) {
        localStorage.removeItem(key);
    }
};

// API helper
async function api(endpoint, options = {}) {
    const defaults = {
        headers: {
            'Content-Type': 'application/json',
        },
    };

    const config = { ...defaults, ...options };

    try {
        const response = await fetch(endpoint, config);
        return await response.json();
    } catch (error) {
        console.error('API Error:', error);
        throw error;
    }
}

// Toast notifications
function showToast(message, type = 'info') {
    const toast = document.createElement('div');
    toast.className = `toast toast-${type}`;
    toast.textContent = message;

    // Style the toast
    Object.assign(toast.style, {
        position: 'fixed',
        bottom: '20px',
        right: '20px',
        padding: '1rem 1.5rem',
        borderRadius: '8px',
        color: 'white',
        fontWeight: '500',
        zIndex: '1000',
        animation: 'slideIn 0.3s ease',
        backgroundColor: type === 'success' ? '#10b981' :
                        type === 'error' ? '#ef4444' :
                        type === 'warning' ? '#f59e0b' : '#3b82f6'
    });

    document.body.appendChild(toast);

    setTimeout(() => {
        toast.style.animation = 'slideOut 0.3s ease';
        setTimeout(() => toast.remove(), 300);
    }, 3000);
}

// Add toast animations
const style = document.createElement('style');
style.textContent = `
    @keyframes slideIn {
        from { transform: translateX(100%); opacity: 0; }
        to { transform: translateX(0); opacity: 1; }
    }
    @keyframes slideOut {
        from { transform: translateX(0); opacity: 1; }
        to { transform: translateX(100%); opacity: 0; }
    }
`;
document.head.appendChild(style);

// Date formatting helper
function formatDate(date, locale = 'en') {
    const options = { year: 'numeric', month: 'long', day: 'numeric' };
    return new Date(date).toLocaleDateString(locale, options);
}

// Print page helper
function printPage() {
    window.print();
}

// Share functionality (if supported)
async function sharePage(title, text, url) {
    if (navigator.share) {
        try {
            await navigator.share({ title, text, url });
        } catch (err) {
            console.log('Share cancelled');
        }
    } else {
        // Fallback: copy to clipboard
        navigator.clipboard.writeText(url);
        showToast('Link copied to clipboard!', 'success');
    }
}

// Accessibility: Keyboard navigation for custom elements
document.addEventListener('keydown', function(e) {
    // Enter or Space activates buttons
    if ((e.key === 'Enter' || e.key === ' ') && e.target.matches('[role="button"]')) {
        e.preventDefault();
        e.target.click();
    }
});

// Check if user prefers reduced motion
const prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

if (prefersReducedMotion) {
    document.documentElement.style.setProperty('--transition', 'none');
}

// Initialize on DOM ready
document.addEventListener('DOMContentLoaded', function() {
    // Add loaded class for animations
    document.body.classList.add('loaded');

    // Initialize any date inputs with today as min
    document.querySelectorAll('input[type="date"]').forEach(input => {
        if (!input.hasAttribute('min')) {
            input.min = new Date().toISOString().split('T')[0];
        }
    });
});

// Service Worker registration for offline support (optional)
if ('serviceWorker' in navigator && window.location.protocol === 'https:') {
    window.addEventListener('load', function() {
        navigator.serviceWorker.register('/sw.js').catch(function(err) {
            console.log('ServiceWorker registration failed: ', err);
        });
    });
}

console.log('Refugee Healthcare Platform initialized');
