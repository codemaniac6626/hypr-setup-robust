let selectedAesthetic = null;
let selectedFunctional = null;

let currentAesthetic = null;
let currentFunctional = null;

let currentView = 'apply';

window.addEventListener('pywebviewready', async function() {
    await loadData();
    
    document.getElementById('close-btn').addEventListener('click', () => {
        pywebview.api.close_app();
    });

    document.getElementById('apply-btn').addEventListener('click', applySelection);

    function switchView(targetView) {
        document.getElementById('apply-view').classList.add('hidden');
        document.getElementById('save-view').classList.add('hidden');
        document.getElementById('kb-view').classList.add('hidden');
        document.getElementById(`${targetView}-view`).classList.remove('hidden');
        currentView = targetView;
    }

    document.getElementById('toggle-apply-btn').addEventListener('click', () => {
        switchView('apply');
    });

    document.getElementById('toggle-view-btn').addEventListener('click', () => {
        switchView('save');
    });

    document.getElementById('toggle-kb-btn').addEventListener('click', () => {
        switchView('kb');
        loadKeybindings();
    });

    document.getElementById('save-aesthetic-btn').addEventListener('click', async () => {
        const input = document.getElementById('save-aesthetic-input');
        const name = input.value;
        const btn = document.getElementById('save-aesthetic-btn');
        btn.disabled = true;
        const result = await pywebview.api.save_theme('aesthetic', name);
        showToast(result.message, result.status === 'error');
        if (result.status === 'success') {
            input.value = '';
            await loadData();
        }
        btn.disabled = false;
    });

    document.getElementById('save-functional-btn').addEventListener('click', async () => {
        const input = document.getElementById('save-functional-input');
        const name = input.value;
        const btn = document.getElementById('save-functional-btn');
        btn.disabled = true;
        const result = await pywebview.api.save_theme('functional', name);
        showToast(result.message, result.status === 'error');
        if (result.status === 'success') {
            input.value = '';
            await loadData();
        }
        btn.disabled = false;
    });
});

async function loadData() {
    // Get currently active themes
    currentAesthetic = await pywebview.api.get_current_aesthetic();
    currentFunctional = await pywebview.api.get_current_functional();

    selectedAesthetic = currentAesthetic;
    selectedFunctional = currentFunctional;

    // Get all available themes
    const aesthetics = await pywebview.api.get_aesthetics();
    const functionals = await pywebview.api.get_functionals();

    renderList('aesthetic-list', aesthetics, currentAesthetic, (item) => {
        selectedAesthetic = item;
        updateSelection('aesthetic-list', selectedAesthetic);
        updateApplyButton();
    });

    renderList('functional-list', functionals, currentFunctional, (item) => {
        selectedFunctional = item;
        updateSelection('functional-list', selectedFunctional);
        updateApplyButton();
    });

    updateSelection('aesthetic-list', selectedAesthetic);
    updateSelection('functional-list', selectedFunctional);
    updateApplyButton();
}

function renderList(containerId, items, currentActive, onClick) {
    const container = document.getElementById(containerId);
    container.innerHTML = '';

    if (items.length === 0) {
        container.innerHTML = '<div style="padding:15px; color:var(--text-secondary); font-size: 14px;">No themes found.</div>';
        return;
    }

    items.forEach(item => {
        const el = document.createElement('div');
        el.className = 'theme-item';
        if (item === currentActive) {
            el.classList.add('active-current');
        }
        
        el.dataset.id = item;

        const nameSpan = document.createElement('span');
        nameSpan.className = 'theme-name';
        nameSpan.textContent = item;

        el.appendChild(nameSpan);
        
        el.addEventListener('click', () => onClick(item));
        
        container.appendChild(el);
    });
}

function updateSelection(containerId, selectedItem) {
    const container = document.getElementById(containerId);
    const items = container.querySelectorAll('.theme-item');
    
    items.forEach(el => {
        if (el.dataset.id === selectedItem) {
            el.classList.add('selected');
        } else {
            el.classList.remove('selected');
        }
    });
}

function updateApplyButton() {
    const btn = document.getElementById('apply-btn');
    if (!selectedAesthetic && !selectedFunctional) {
        btn.disabled = true;
    } else {
        btn.disabled = false;
    }
}

async function applySelection() {
    const btn = document.getElementById('apply-btn');
    btn.disabled = true;
    btn.textContent = 'EXECUTING...';

    // Wait a brief moment for the UI update to show
    await new Promise(r => setTimeout(r, 100));

    const result = await pywebview.api.apply_themes(selectedAesthetic, selectedFunctional);

    if (result.status === 'success') {
        showToast(result.message, false);
        // Reload data to update 'ACTIVE' tags
        await loadData();
    } else {
        showToast(result.message, true);
    }

    btn.textContent = 'EXECUTE SEQUENCE';
    updateApplyButton();
}

function showToast(message, isError) {
    const toast = document.getElementById('toast');
    const toastMsg = document.getElementById('toast-message');
    
    toastMsg.textContent = message;
    
    if (isError) {
        toast.classList.add('error');
    } else {
        toast.classList.remove('error');
    }
    
    toast.classList.remove('hidden');
    
    setTimeout(() => {
        toast.classList.add('hidden');
    }, 3000);
}

let allKeybindings = [];

async function loadKeybindings() {
    allKeybindings = await pywebview.api.get_keybindings();
    renderKeybindings(allKeybindings);
}

function renderKeybindings(bindings) {
    const container = document.getElementById('kb-list');
    container.innerHTML = '';

    if (!bindings || bindings.length === 0) {
        container.innerHTML = '<div style="padding:15px; color:var(--text-secondary); font-size: 14px;">No keybindings found for the current functional theme.</div>';
        return;
    }

    bindings.forEach(kb => {
        const el = document.createElement('div');
        el.className = 'kb-item';
        
        let displayStr = kb.modifiers;
        if (kb.modifiers && kb.key) displayStr += ' + ';
        displayStr += kb.key;

        let cmdStr = kb.action;
        if (kb.command) cmdStr += ' ' + kb.command;

        el.innerHTML = `
            <div class="kb-keys">${displayStr}</div>
            <div class="kb-command">${cmdStr}</div>
            ${kb.comment ? `<div class="kb-comment">${kb.comment}</div>` : ''}
        `;
        
        container.appendChild(el);
    });
}

document.getElementById('kb-search').addEventListener('input', (e) => {
    const term = e.target.value.toLowerCase();
    const filtered = allKeybindings.filter(kb => {
        const keys = (kb.modifiers + " " + kb.key).toLowerCase();
        const cmd = (kb.action + " " + kb.command).toLowerCase();
        const cmt = (kb.comment || "").toLowerCase();
        return keys.includes(term) || cmd.includes(term) || cmt.includes(term);
    });
    renderKeybindings(filtered);
});
