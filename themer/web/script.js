let selectedThemeSet = null;
let selectedAesthetic = null;
let selectedFunctional = null;
let selectedWallpaper = null;

let currentThemeSet = null;
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
        document.getElementById('wallpapers-view').classList.add('hidden');
        document.getElementById(`${targetView}-view`).classList.remove('hidden');
        currentView = targetView;
    }

    document.getElementById('toggle-apply-btn').addEventListener('click', () => {
        switchView('apply');
    });

    document.getElementById('toggle-view-btn').addEventListener('click', () => {
        switchView('save');
        loadDirtyFiles();
    });

    document.getElementById('toggle-kb-btn').addEventListener('click', () => {
        switchView('kb');
        loadKeybindings();
    });

    document.getElementById('toggle-walls-btn').addEventListener('click', () => {
        switchView('wallpapers');
        loadWallpapers();
    });

    document.getElementById('apply-wall-btn').addEventListener('click', async () => {
        if (!selectedWallpaper) return;
        const btn = document.getElementById('apply-wall-btn');
        btn.disabled = true;
        btn.textContent = 'APPLYING...';
        
        const result = await pywebview.api.apply_wallpaper(selectedWallpaper);
        showToast(result.message, result.status === 'error');
        
        btn.textContent = 'APPLY WALLPAPER';
        btn.disabled = false;
    });

    document.getElementById('save-aesthetic-btn').addEventListener('click', async () => {
        const input = document.getElementById('save-aesthetic-input');
        const name = input.value;
        const btn = document.getElementById('save-aesthetic-btn');
        btn.disabled = true;
        const result = await pywebview.api.save_theme(currentThemeSet, 'aesthetic', name);
        showToast(result.message, result.status === 'error');
        if (result.status === 'success') {
            input.value = '';
            await loadData();
            if (currentView === 'save') loadDirtyFiles();
        }
        btn.disabled = false;
    });

    document.getElementById('save-functional-btn').addEventListener('click', async () => {
        const input = document.getElementById('save-functional-input');
        const name = input.value;
        const btn = document.getElementById('save-functional-btn');
        btn.disabled = true;
        const result = await pywebview.api.save_theme(currentThemeSet, 'functional', name);
        showToast(result.message, result.status === 'error');
        if (result.status === 'success') {
            input.value = '';
            await loadData();
            if (currentView === 'save') loadDirtyFiles();
        }
        btn.disabled = false;
    });

    document.getElementById('save-new-theme-set-btn').addEventListener('click', async () => {
        const setName = prompt("Enter name for the new theme-set:");
        if (!setName) return;
        
        const aestheticName = document.getElementById('save-aesthetic-input').value;
        const functionalName = document.getElementById('save-functional-input').value;
        
        const btn = document.getElementById('save-new-theme-set-btn');
        btn.disabled = true;
        btn.textContent = 'SAVING...';
        
        const result = await pywebview.api.save_new_theme_set(setName, aestheticName, functionalName);
        showToast(result.message, result.status === 'error');
        if (result.status === 'success') {
            document.getElementById('save-aesthetic-input').value = '';
            document.getElementById('save-functional-input').value = '';
            selectedThemeSet = setName;
            await loadData();
            if (currentView === 'save') loadDirtyFiles();
        }
        btn.textContent = 'SAVE AS NEW THEME-SET';
        btn.disabled = false;
    });
    
    document.getElementById('theme-set-select').addEventListener('change', async (e) => {
        selectedThemeSet = e.target.value;
        await loadData();
    });
});

async function loadData() {
    currentThemeSet = await pywebview.api.get_current_theme_set();
    if (!selectedThemeSet) selectedThemeSet = currentThemeSet;

    const themeSets = await pywebview.api.get_theme_sets();
    populateThemeSetSelect(themeSets, selectedThemeSet);

    // Get currently active themes for the selected theme set
    currentAesthetic = await pywebview.api.get_current_aesthetic(selectedThemeSet);
    currentFunctional = await pywebview.api.get_current_functional(selectedThemeSet);

    selectedAesthetic = currentAesthetic;
    selectedFunctional = currentFunctional;

    // Get all available themes
    const aesthetics = await pywebview.api.get_aesthetics(selectedThemeSet);
    const functionals = await pywebview.api.get_functionals(selectedThemeSet);

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

    populateDatalist('aesthetic-datalist', aesthetics);
    populateDatalist('functional-datalist', functionals);
}

function populateThemeSetSelect(themeSets, activeSet) {
    const select = document.getElementById('theme-set-select');
    if (!select) return;
    
    select.innerHTML = '';
    themeSets.forEach(ts => {
        const option = document.createElement('option');
        option.value = ts;
        option.textContent = ts + (ts === currentThemeSet ? ' (Active)' : '');
        if (ts === activeSet) {
            option.selected = true;
        }
        select.appendChild(option);
    });
}

function populateDatalist(datalistId, items) {
    const datalist = document.getElementById(datalistId);
    if (!datalist) return;
    datalist.innerHTML = '';
    items.forEach(item => {
        const option = document.createElement('option');
        option.value = item;
        datalist.appendChild(option);
    });
}

async function loadDirtyFiles() {
    const aestheticList = document.getElementById('aesthetic-dirty-list');
    const functionalList = document.getElementById('functional-dirty-list');
    
    if (aestheticList) aestheticList.innerHTML = '<div style="padding:10px; color:var(--text-secondary); font-size: 12px;">Checking...</div>';
    if (functionalList) functionalList.innerHTML = '<div style="padding:10px; color:var(--text-secondary); font-size: 12px;">Checking...</div>';

    const dirtyFiles = await pywebview.api.get_dirty_files();
    
    renderDirtyList('aesthetic-dirty-list', dirtyFiles.aesthetic);
    renderDirtyList('functional-dirty-list', dirtyFiles.functional);
}

function renderDirtyList(containerId, files) {
    const container = document.getElementById(containerId);
    if (!container) return;
    
    container.innerHTML = '';
    
    if (!files || files.length === 0) {
        container.innerHTML = '<div class="dirty-item synced">󰄵 All files synced.</div>';
        return;
    }
    
    files.forEach(file => {
        const el = document.createElement('div');
        el.className = 'dirty-item';
        el.textContent = '󰏫 ' + file;
        container.appendChild(el);
    });
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

    const result = await pywebview.api.apply_themes(selectedThemeSet, selectedAesthetic, selectedFunctional);

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

let allWallpapers = {};

async function loadWallpapers() {
    allWallpapers = await pywebview.api.get_wallpapers();
    renderWallpapers();
}

function renderWallpapers() {
    const container = document.getElementById('wallpaper-container');
    if (!container) return;
    container.innerHTML = '';
    
    if (!allWallpapers || Object.keys(allWallpapers).length === 0) {
        container.innerHTML = '<div style="padding:15px; color:var(--text-secondary); font-size: 14px;">No wallpapers found in ~/Pictures/wallpapers.</div>';
        return;
    }
    
    for (const [folder, paths] of Object.entries(allWallpapers)) {
        const folderHeader = document.createElement('h3');
        folderHeader.style.color = 'var(--neon-color)';
        folderHeader.style.marginTop = '15px';
        folderHeader.style.marginBottom = '10px';
        folderHeader.style.borderBottom = '1px dashed var(--border-color)';
        folderHeader.style.paddingBottom = '5px';
        folderHeader.style.fontSize = '14px';
        folderHeader.style.textTransform = 'uppercase';
        folderHeader.style.letterSpacing = '1px';
        folderHeader.textContent = folder;
        
        container.appendChild(folderHeader);
        
        const folderGrid = document.createElement('div');
        folderGrid.className = 'wallpaper-folder-grid';
        
        paths.forEach(item => {
            const el = document.createElement('div');
            el.className = 'wallpaper-item';
            if (item.abs_path === selectedWallpaper) el.classList.add('selected');
            
            const img = document.createElement('img');
            img.src = 'wallpapers/' + item.rel_path;
            
            el.appendChild(img);
            
            el.addEventListener('click', () => {
                selectedWallpaper = item.abs_path;
                renderWallpapers();
                updateApplyWallButton();
            });
            
            folderGrid.appendChild(el);
        });
        
        container.appendChild(folderGrid);
    }
    updateApplyWallButton();
}

function updateApplyWallButton() {
    const btn = document.getElementById('apply-wall-btn');
    if (btn) btn.disabled = !selectedWallpaper;
}
