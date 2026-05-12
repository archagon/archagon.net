# Setup

## Basics

1. prerequisites
    * homebrew
    * rbenv
    * ruby-build (possibly needed for rbenv intstall)
    * Xcode (needed for rbenv install)
2. `rbenv install 4.0.3`
3. `rbenv local 4.0.3`
4. `rbenv init` (to setup path)
5. check `ruby --version`, troubleshoot here: https://stackoverflow.com/a/12150580
6. `brew install imagemagick` (need to do some crazy stuff for rmagick: https://stackoverflow.com/a/43035892)
7. `gem install jekyll`
8. `gem install stringex`
9. `gem install nokogiri`
10. `gem install imgkit`
11. `gem install rmagick`
12. `gem install jekyll-redirect-from`
13. `gem install jekyll-paginate`
14. `gem install jekyll-paginate-category`
15. (optionally?) install wkhtmltoimage (I had to use an installer)

Build site with `rake build` and locally host site with `rake serve`.

## Other Stuff

* install wkhtmltopdf
* create an 'images' directory

```
archagon@Alexeis-MacBook-Pro-2 Blog % gem install imgkit
Fetching imgkit-1.6.3.gem
******************************************************************

Now install wkhtmltoimage binaries:
Global: sudo `which imgkit` --install-wkhtmltoimage
        rvmsudo imgkit --install-wkhtmltoimage
(installs to default /usr/local/bin/wkhtmltoimage)

inside RVM folder: export TO=`which imgkit | sed 's:/imgkit:/wkhtmltoimage:'` && imgkit --install-wkhtmltoimage
(you'll have to configure the location of the binary if you do this!)

(run imgkit --help to see more options)
******************************************************************
Successfully installed imgkit-1.6.3
Parsing documentation for imgkit-1.6.3
Installing ri documentation for imgkit-1.6.3
Done installing documentation for imgkit after 0 seconds
1 gem installed
```