require_relative "prelude"

require "open3"
require "shellwords"
require "fileutils"

scope do
  def assert_empty(str)
    assert(str.size == 0)
  end

  setup do
    root = File.join(File.expand_path(File.join(File.dirname(__FILE__), "..")))

    FileUtils.rm_rf(File.join(root, "test/tmp"))

    capture = -> cmd do
      out, err, status = Open3.capture3(cmd)

      [out.rstrip, err.rstrip, status.exitstatus]
    end

    sh = -> executable, env do
      -> args = [] do
        command = %Q[cd #{root} && #{env.map { |k, v| "#{k}=#{v}" }.join(" ")} #{executable} #{Shellwords.join(args)}]

        capture.(command)
      end
    end

    [sh.("./bin/bjob", {}), sh, capture, root]
  end

  test "prints a help message on no arguments" do |bjob, _|
    out, err, status = bjob.()

    assert_empty err
    assert_equal status, 1
  end

  test "runs a job" do |bjob, _|
    out, err, status = bjob.(%w[-r ./test/jobs/ten Ten])

    assert_equal "0", File.read("test/tmp/ten/0.txt")
    assert_equal "1", File.read("test/tmp/ten/1.txt")

    assert_equal status, 0
  end

  test "is silent on non-terminals by default" do |bjob, _|
    out, err, status = bjob.(%w[-r ./test/jobs/ten Ten])

    assert_empty out
    assert_empty err
  end

  test "is interactive on terminals by default" do |bjob, sh|
    out, err, status = sh.("./bin/bjob", "PS1" => "$").(%w[-r ./test/jobs/ten Ten])

    assert_equal out, "  0% ..........\n100%"
    assert_empty err
  end

  test "can be forced to be non interactive with -s" do |bjob, sh|
    out, err, status = sh.("./bin/bjob", "PS1" => "$").(%w[-r ./test/jobs/ten Ten -s])

    assert_empty out
    assert_empty err
  end

  test "can be forced to be interactive with -i" do |bjob, _|
    out, err, status = bjob.(%w[-i -r ./test/jobs/ten Ten])

    assert_equal out, "  0% ..........\n100%"
    assert_empty err
  end

  test "picks up .bjobrc" do |bjob, _, capture, root|
    out, err, status = capture.(%Q[cd #{File.join(root, "test/roots/bjobrc-ten")} && #{File.join(root, "bin/bjob")} Ten])

    assert_equal "0", File.read("test/tmp/ten/0.txt")
    assert_equal "1", File.read("test/tmp/ten/1.txt")

    assert_empty err
  end
end
