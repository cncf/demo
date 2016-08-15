from setuptools import setup, find_packages

setup(
    name='cncf',
    version='0.1',
    packages=['cncfdemo'],
    include_package_data=True,
    install_requires=[
        'click',
        'requests',
        'glob2',
        'pyyaml',
        'jinja2',
        'boto',
    ],
    entry_points='''
        [console_scripts]
        cncfdemo=cncfdemo.cncf:cli
    ''',
)
