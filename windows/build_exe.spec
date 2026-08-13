# -*- mode: python ; coding: utf-8 -*-

import os

block_cipher = None
base_dir = os.path.dirname(os.path.abspath(SPECPATH))

a = Analysis(
    ['app.py'],
    pathex=[base_dir],
    binaries=[],
    datas=[
        ('core', 'core'),
        ('font', 'font'),
    ],
    hiddenimports=[
        'customtkinter',
        'PIL',
        'PIL._tkinter_finder',
        'cv2',
        'numpy',
        'requests',
        'cloudinary',
        'cloudinary.uploader',
        'cloudinary.api',
        'google.oauth2.credentials',
        'google.auth.transport.requests',
        'google_auth_oauthlib.flow',
        'googleapiclient.discovery',
        'googleapiclient.http',
        'core',
        'core.config_manager',
        'core.project_manager',
        'core.gemini_manager',
        'core.ui_helpers',
        'core.setup_wizard',
        'core.dashboard_frame',
        'core.settings_frame',
        'core.publish_frame',
        'core.mask_editor',
        'core.watermark_editor',
        'publisher',
    ],
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=[],
    win_no_prefer_redirects=False,
    win_private_assemblies=False,
    cipher=block_cipher,
    noarchive=False,
)

pyz = PYZ(a.pure, a.zipped_data, cipher=block_cipher)

exe = EXE(
    pyz,
    a.scripts,
    [],
    exclude_binaries=True,
    name='Apollo',
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    console=False,
    disable_windowed_traceback=False,
    argv_emulation=False,
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
    icon='apollo.ico',
)

coll = COLLECT(
    exe,
    a.binaries,
    a.zipfiles,
    a.datas,
    strip=False,
    upx=True,
    upx_exclude=[],
    name='Apollo',
)