# Liquid 4.0.3 (pinned by github-pages 223) still calls String#tainted?.
# Ruby 3.2+ removed taint. GitHub Pages production ships a newer Liquid;
# CI uses our lockfile on Ruby 3.3, so restore the no-op methods for the build.
class Object
  def tainted?
    false
  end

  def taint
    self
  end

  def untaint
    self
  end
end
