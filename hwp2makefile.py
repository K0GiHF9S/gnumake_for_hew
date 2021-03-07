import sys
import os
from pathlib import Path, PurePosixPath, PureWindowsPath
import re

C_PREFIX = '.c'
CPP_PREFIX = '.cpp'
AS_PREFIX = '.src'


def read_hwp(p_filename, config):
    with open(p_filename, 'r', encoding='cp932') as f:
        data = f.read()
    return data.replace('\\', '/') \
        .replace('^"', '') \
        .replace('$(PROJDIR)', '.') \
        .replace('$(CONFIGDIR)', config) \
        .replace('$(CONFIGNAME)', config) \
        .replace('$(PROJECTNAME)', p_filename.stem)


def filter_parent_dir(data):
    return re.findall(
        '\[PROJECT_DETAILS\]\n"\w+" "(.*?)"', data, flags=re.MULTILINE)[0]


def filter_src_files(data, record_dir):
    project_files_area = re.findall(
        '\[PROJECT_FILES\]\n((?:.*\n)*?)\[', data, flags=re.MULTILINE)[0]
    project_files = re.findall(
        '^"(.*?)"', project_files_area, flags=re.MULTILINE)
    project_files = [str(PureWindowsPath(f).relative_to(
        record_dir)) for f in project_files]

    c_project_files = [f for f in project_files if f.endswith(C_PREFIX)]
    cpp_project_files = [f for f in project_files if f.endswith(CPP_PREFIX)]
    asm_project_files = [f for f in project_files if f.endswith(AS_PREFIX)]
    return c_project_files, cpp_project_files, asm_project_files


def to_option_dict(data, config):
    option_area = re.findall(
        f'\[OPTIONS_{config}\]\n((?:.*\n)*?)\[', data, flags=re.MULTILINE)
    if len(option_area) != 1:
        print('Undefined config name.')
        sys.exit(1)
    option_area = option_area[0]
    option_datas = re.findall(
        '^.*\[S\|GBR\|.*\n', option_area, flags=re.MULTILINE)
    option_datas = [re.sub('\[S\|LISTPATH\|.*?\] ', '', d)
                    for d in option_datas]
    option_datas = [re.sub('\[S\|LANG\|.*?\] ', '', d) for d in option_datas]
    if len(set(option_datas)) != 1:
        print('Not supported option.')
        sys.exit(1)

    def to_dict(d): return {k: v.split('|') for (k, v) in re.findall(
        '\[\w\|(\w+)\|([^\]]*)\]', d)}

    option_data = to_dict(option_datas[0])

    link_option_data = re.findall(
        '^.*\[S\|FORM\|.*\n', option_area, flags=re.MULTILINE)
    link_option_data = to_dict(link_option_data[0])

    optimize_option_data = re.findall(
        '^.*\[S\|START\|.*\n', option_area, flags=re.MULTILINE)
    if len(optimize_option_data) > 0:
        optimize_option_data = to_dict(optimize_option_data[0])
    else:
        optimize_option_data = None
    return option_data, link_option_data, optimize_option_data


def filter_include_dirs(option_data):
    return option_data.get('INCLUDE', '')


def filter_defines(option_data):
    return option_data.get('DEFINE', '')


def filter_libs(link_option_data):
    return link_option_data.get('INPUTLIBRARY', '')


def filter_sections(optimize_option_data):
    start = ','.join(optimize_option_data['START'])
    return re.sub('\(([\dA-F]+)\)', r'/\1', start)


def hwp2rule(filename, config):
    p_infile = Path(filename)
    data = read_hwp(p_infile, config)
    p_outfile = p_infile.with_suffix(f'.mak.{config}').resolve()
    p_lnkfile = p_infile.with_suffix(f'.lnk.{config}').resolve()
    os.chdir(p_infile.parent)

    Path(config).mkdir(exist_ok=True)

    record_dir = filter_parent_dir(data)
    option_data, link_option_data, optimize_option_data = to_option_dict(
        data, config)

    c_project_files, cpp_project_files, asm_project_files = filter_src_files(
        data, record_dir)
    v = 'C_SRC := ' + ' \\\n\t'.join(c_project_files) + '\n'
    v += 'CXX_SRC := ' + ' \\\n\t'.join(cpp_project_files) + '\n'
    v += 'AS_SRC := ' + ' \\\n\t'.join(asm_project_files) + '\n'

    include_dirs = filter_include_dirs(option_data)
    v += 'INCLUDE := ' + ' '.join(include_dirs) + '\n'

    defines = filter_defines(option_data)
    v += 'DEFINE := ' + ' '.join(defines) + '\n'

    libs = filter_libs(link_option_data)
    v += 'LIBS := ' + ' '.join(libs) + '\n'

    with open(p_outfile, 'w', encoding='utf8') as f:
        f.write(v)

    c = '\n'.join([f'-input=./{config}/' + PurePosixPath(s).with_suffix('.obj').name
                   for s in (c_project_files + cpp_project_files + asm_project_files)]) + '\n'

    if optimize_option_data is not None:
        sections = filter_sections(optimize_option_data)
        c += f'-start={sections}\n'

    with open(p_lnkfile, 'w', encoding='cp932') as f:
        f.write(c)


if __name__ == '__main__':
    if len(sys.argv) < 3:
        sys.exit(1)
    hew_path = sys.argv[1]
    config = sys.argv[2]
    hwp2rule(hew_path, config)
