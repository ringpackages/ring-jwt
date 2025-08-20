function showSection(id) {
    document.querySelectorAll('.section').forEach(s => s.classList.add('hidden'));
    document.getElementById(id).classList.remove('hidden');
}

function showStatus(msg, type = "info") {
    const toastContainer = document.querySelector('.toast-container');
    const toastId = `toast-${Date.now()}`;
    const bgColorClass = {
        "info": "text-bg-info",
        "success": "text-bg-success",
        "danger": "text-bg-danger"
    }[type] || "text-bg-info";

    function getIconClass(type) {
        switch (type) {
            case "success": return "bi-check-circle-fill";
            case "danger": return "bi-exclamation-triangle-fill";
            case "info": return "bi-info-circle-fill";
            default: return "bi-info-circle-fill";
        }
    }

    const toastHtml = `
        <div id="${toastId}" class="toast align-items-center ${bgColorClass} border-0 animate__animated animate__fadeInRight" role="alert" aria-live="assertive" aria-atomic="true">
            <div class="d-flex">
                <div class="toast-body d-flex align-items-center">
                    <i class="bi ${getIconClass(type)} me-2"></i>
                    ${msg}
                </div>
                <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast" aria-label="Close"></button>
            </div>
        </div>
    `;

    toastContainer.insertAdjacentHTML('beforeend', toastHtml);
    const toastEl = document.getElementById(toastId);
    const toast = new bootstrap.Toast(toastEl);
    toast.show();

    toastEl.addEventListener('hidden.bs.toast', () => {
        toastEl.remove();
    });
}

function updateResponseArea(data) {
    const el = document.getElementById('responseArea');
    el.classList.remove('animate__animated', 'animate__fadeIn'); 
    el.textContent = typeof data === "string" ? data : JSON.stringify(data, null, 2);
    void el.offsetWidth; 
    el.classList.add('animate__animated', 'animate__fadeIn'); 
}

async function checkAuth() {
    try {
        const res = await fetch('/api/auth', { credentials: 'include' });
        const data = await res.json();
        if (data.authenticated) {
            document.getElementById('displayUsername').textContent = data.user;
            document.getElementById('displayRole').textContent = data.role || "N/A";
            const expiresDate = unixToLocalString(data.expiresat);
            document.getElementById('displayExpiresAt').textContent = expiresDate.toLocaleString();

            showSection('tokenSection');
            document.getElementById('protectedSection').classList.remove('hidden');
        } else {
            showSection('loginSection');
            document.getElementById('protectedSection').classList.add('hidden');
        }
    } catch {
        showSection('loginSection');
        document.getElementById('protectedSection').classList.add('hidden');
    }
}

document.getElementById('loginForm').addEventListener('submit', async function (e) {
    e.preventDefault();
    const username = document.getElementById('username').value.trim();
    const password = document.getElementById('password').value;
    try {
        const res = await fetch('/api/login', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ username, password })
        });
        const data = await res.json();
        if (res.ok && data.success) {
            showStatus(data.message, "success");
            await checkAuth();
        } else {
            showStatus(data.message || "Login failed", "danger");
        }
    } catch {
        showStatus("Network error", "danger");
    }
});

document.getElementById('refreshTokenBtn').addEventListener('click', async function () {
    try {
        const res = await fetch('/api/refresh', { method: 'POST' });
        const data = await res.json();
        if (res.ok && data.success) {
            showStatus(data.message, "success");
            await checkAuth();
        } else {
            showStatus(data.message || "Refresh failed", "danger");
        }
    } catch {
        showStatus("Network error", "danger");
    }
});

document.getElementById('logoutBtn').addEventListener('click', async function () {
    try {

        const res = await fetch('/api/logout', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ refreshToken: "" })
        });
        const data = await res.json();
        showStatus(data.message || "Logged out", "info");
        showSection('loginSection');
        document.getElementById('protectedSection').classList.add('hidden');
    } catch {
        showStatus("Network error", "danger");
    }
});

document.getElementById('getProtectedBtn').addEventListener('click', async function () {
    try {
        const res = await fetch('/api/protected');
        const data = await res.json();
        updateResponseArea(data);
        if (res.ok) {
            showStatus("Protected data loaded", "success");
        } else {
            showStatus(data.message || "Access denied", "danger");
        }
    } catch {
        updateResponseArea("Network error");
        showStatus("Network error", "danger");
    }
});

document.getElementById('getProfileBtn').addEventListener('click', async function () {
    try {
        const res = await fetch('/api/profile');
        const data = await res.json();
        updateResponseArea(data);
        if (res.ok) {
            showStatus("Profile loaded", "success");
        } else {
            showStatus(data.message || "Access denied", "danger");
        }
    } catch {
        updateResponseArea("Network error");
        showStatus("Network error", "danger");
    }
});

window.addEventListener('DOMContentLoaded', async () => {
    await checkAuth();
});

function unixToLocalString(unixTimestamp) {
    if (!unixTimestamp || isNaN(unixTimestamp)) return "";
    const date = new Date(unixTimestamp * 1000);
    return date.toLocaleString();
}