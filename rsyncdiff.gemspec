Gem::Specification.new do |s|
  s.name = %q{rsyncdiff}
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Alex R. Young"]
  s.date = %q{2009-09-16}
  s.description = %q{rsyncdiff is a tool for comparing local and remote code.  It displays changes, deletions and diffs.}
  s.email = %q{alex@alexyoung.org}
  s.files = %w{README.textile bin/rsyncdiff}
  s.has_rdoc = false
  s.bindir = 'bin'
  s.executables = ['rsyncdiff']
  s.default_executable = 'bin/rsyncdiff'
  s.homepage = %q{http://github.com/alexyoung/rsyncdiff}
  s.summary = %q{rsyncdiff is a tool for comparing local and remote code.}
end

