use Thread::Pool::Simple;
use Test::WWW::Selenium;
use Selenium::Remote::Driver;

my $extraCaps = { 
  "browser" => "IE",
  "browser_version" => "8.0",
  "os" => "Windows",
  "os_version" => "7",
  "browserstack.debug" => "true"
};
 
sub browserstack_test() {
    my ($url, $input) = @_; 
	my $login = "USERNAME";
	my $key = "ACCESS_KEY";
	my $host = "$login:$key\@hub.browserstack.com";
	my $driver = new Selenium::Remote::Driver('remote_server_addr' => $host, 
	  'port' => '80', 'extra_capabilities' => $extraCaps);
	$driver->get($url);
	$driver->find_element($input,'name')->send_keys("BrowserStack");
	print $driver->get_title();
	$driver->quit();
}

sub test_google() {
    &browserstack_test("http://google.com", "q");
}
 
sub test_yahoo() {
    &browserstack_test("http://yahoo.com", "p");
}
 
sub test_bing() {
    &browserstack_test("http://www.bing.com", "q");
}

sub worker() {
    my $func = shift;
    eval("&$func();"); #can't pass CODE items to a pool
}

my $pool = Thread::Pool::Simple->new(
    min => 3,
    max => 10,
    do => [\&worker],
);
 
my @test_names = (
    "test_google",
    "test_yahoo",
    "test_bing",
);

foreach $test (@test_names) {
    print "Adding $test\n";
    $pool->add($test);
}

$pool->join();