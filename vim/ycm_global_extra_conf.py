#!/usr/bin/env python3
# ---------------------------------------------------------
#   Name: ycm_global_extra_conf.py
#   Author: xyy15926
#   Created: 2025-09-22 20:13:35
#   Updated: 2025-09-22 20:13:35
#   Description:
# ---------------------------------------------------------

def Settings( **kwargs ):
    client_data = kwargs[ 'client_data' ]
    return {
        'interpreter_path': client_data[ 'g:ycm_python_interpreter_path' ],
        'sys_path': client_data[ 'g:ycm_python_sys_path' ]
    }
