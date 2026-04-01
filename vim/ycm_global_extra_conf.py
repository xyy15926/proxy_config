#!/usr/bin/env python3
# ---------------------------------------------------------
#   Name: ycm_global_extra_conf.py
#   Author: xyy15926
#   Created: 2025-09-22 20:13:35
#   Updated: 2026-02-01 10:40:59
#   Description:
# ---------------------------------------------------------

def Settings(**kwargs):
    """YCMD extra conf.

    Global extra conf loaded by YCM for YCMD, the code-completer and
    comprehensive server seperated from the original YCM project.
    And now vim-YCM, vscode-YCM, nano-YCM are all clients working along
    with YCMD.

    Ref:
    ---------------------------
    - https://github.com/ycm-core/ycmd

    Params:
    ---------------------------
    client_data: Dict.
      KV-pair specified by `g:ycm_extra_conf_vim_data` in `vimrc`.

    Return:
    ---------------------------
    Dict as the extra conf.

    Valid key for Python Project:
    ---------------------------
    interpreter_path: Interpreter path.
    sys_path: Additional thirdparty paths that will be added to `sys.path`
      dynamicly. This enable YCM could find the thirdparty paths which are
      not related to the `interpreter_path`.
    """
    client_data = kwargs["client_data"]     # Any additional data supplied by the client app, vim-YCM here.
    lang = kwargs["language"]               # An Indentifier of the completer
    filename = kwargs["filename"]
    if lang == "python":
        return {
            "interpreter_path": client_data[ "g:ycm_python_interpreter_path" ],
            "sys_path": client_data[ "g:ycm_python_sys_path" ]
        }
    elif lang == "rust":
        return {
            # `ls` will be passed to Language Server as the initialization
            # settings that will override the setting in
            # `g:ycm_language_server` in `vimrc`
            "ls": {
                "semanticTokenColorCustomizations.enabled": False,
            }
        }
    # Libclang and clang-based completer.
    elif lang == "cfamily":
        return {}
    else:
        return {}


# def PythonSysPath( **kwargs ):
#     """Modify the python `sys.path`.

#     Customize python `sys.path`.

#     Params:
#     ---------------------------
#     sys_path: Dict.
#       Default sys-path.
#     interpreter_path: Interpreter path.

#     Return:
#     ---------------------------
#     Dict that will used as `sys.path`.
#     """
#     sys_path = kwargs[ "sys_path" ]
#     sys_path.insert( 1, "/path/to/third_party/package" )
#     return sys_path
