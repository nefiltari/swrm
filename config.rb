# Ruby Version: ruby-2.0.0-p0

module SWRM
  Config = {
    repo: {
      path: "#{Dir.home}/.storage/repo/"
    },
    sqlite: {
      path: "#{Dir.home}/.storage",
      name: "sqlite"
    },
    filets: {
      repo: "#{Dir.home}/.storage/tsrepo.nt"
    }
  }
end