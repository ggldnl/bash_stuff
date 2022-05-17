# My collection of bash functions and aliases

This is my collection of bash functions and aliases. Some of the functions are os specific so before sourcing the files we will need to set two variables (well, actually only `OS_NAME` is strictly required) in order to import only the ones that we will actually need on the current system:
```bash
echo "export OS_NAME=\$(head -n 1 /etc/os-release | sed -e 's/^.*=//' -e 's/\"//g')" \
	>> .bashrc
echo "export VERBOSE_SCRIPT=false" >> .bashrc
```

After doing that:

```bash
echo "# aliases & functions" >> .bashrc
echo "source ~/.bash_aliases" >> .bashrc
echo "source ~/.bash_functions" >> .bashrc
```