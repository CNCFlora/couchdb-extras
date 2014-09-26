
require 'rspec'
require_relative '../lib/couch_http'


def run() 
    fork {
        system("ruby -Ilib bin/couchdb2history #{@couch1} #{@couch2} #{@couch3}")
    }
    sleep 1
end

def stop() 
    system("ps -aux | grep couchdb2history  | grep -v grep | awk '{print $2}' | xargs kill -9")
    sleep 1
end

describe "History keeper Sync" do

    before(:all) do
        stop
        @couch1 = "http://localhost:5984"
        @couch2 = "http://localhost:5985"
        @couch3 = "http://localhost:5986"
    end

    before(:each) do
        delete("#{@couch1}/test")
        delete("#{@couch1}/test2")
        delete("#{@couch2}/test3")
        delete("#{@couch1}/test_history")
        delete("#{@couch1}/test2_history")
        delete("#{@couch2}/test3_history")
    end

    after(:all) do
        stop
    end

    it "Simple run and dies" do
        run
        sleep 2
        stop
    end

    it "Sync an existing DB" do
        put("#{@couch1}/test",{})

        run

        d1 = post("#{@couch1}/test",{:_id=>"foo",:foo=>"bar"})
        d2 = post("#{@couch1}/test",{:_id=>"foo1",:foo=>"bar2"})
        d3 = post("#{@couch1}/test",{:_id=>"foo",:foo=>"baz",:_rev=>d1["rev"]})

        sleep 1

        foo1 = get("#{@couch1}/test_history/foo:#{d1["rev"]}")
        expect(foo1["foo"]).to eq("bar")

        foo2 = get("#{@couch1}/test_history/foo1:#{d2["rev"]}")
        expect(foo2["foo"]).to eq("bar2")

        foo3 = get("#{@couch1}/test_history/foo:#{d3["rev"]}")
        expect(foo3["foo"]).to eq("baz")

        stop
    end

    it "Sync an existing DB and new DBs" do
        put("#{@couch1}/test",{})

        run

        put("#{@couch1}/test2",{})

        sleep 1

        d1 = post("#{@couch1}/test2",{:_id=>"foo",:foo=>"bar"})
        d2 = post("#{@couch1}/test2",{:_id=>"foo1",:foo=>"bar2"})
        d3 = post("#{@couch1}/test2",{:_id=>"foo",:foo=>"baz",:_rev=>d1["rev"]})

        sleep 1

        foo1 = get("#{@couch1}/test2_history/foo:#{d1["rev"]}")
        expect(foo1["foo"]).to eq("bar")

        foo2 = get("#{@couch1}/test2_history/foo1:#{d2["rev"]}")
        expect(foo2["foo"]).to eq("bar2")

        foo3 = get("#{@couch1}/test2_history/foo:#{d3["rev"]}")
        expect(foo3["foo"]).to eq("baz")

        stop
    end

    it "Work with multiple servers" do
        run

        put("#{@couch1}/test",{})
        sleep 0.3
        put("#{@couch1}/test2",{})
        sleep 0.3
        put("#{@couch2}/test3",{})
        sleep 0.3

        d11 = post("#{@couch1}/test",{:_id=>"foo",:foo=>"bar"})
        d12 = post("#{@couch1}/test",{:_id=>"foo1",:foo=>"bar21"})
        d13 = post("#{@couch1}/test",{:_id=>"foo",:foo=>"baz",:_rev=>d11["rev"]})

        d21 = post("#{@couch1}/test2",{:_id=>"foo",:foo=>"bar"})
        d22 = post("#{@couch1}/test2",{:_id=>"foo1",:foo=>"bar22"})
        d23 = post("#{@couch1}/test2",{:_id=>"foo",:foo=>"baz",:_rev=>d21["rev"]})

        d31 = post("#{@couch2}/test3",{:_id=>"foo",:foo=>"bar"})
        d32 = post("#{@couch2}/test3",{:_id=>"foo1",:foo=>"bar23"})
        d33 = post("#{@couch2}/test3",{:_id=>"foo",:foo=>"baz",:_rev=>d31["rev"]})

        sleep 1

        foo11 = get("#{@couch1}/test_history/foo:#{d11["rev"]}")
        foo12 = get("#{@couch1}/test_history/foo1:#{d12["rev"]}")
        foo13 = get("#{@couch1}/test_history/foo:#{d13["rev"]}")
        expect(foo11["foo"]).to eq("bar")
        expect(foo12["foo"]).to eq("bar21")
        expect(foo13["foo"]).to eq("baz")

        foo21 = get("#{@couch1}/test2_history/foo:#{d21["rev"]}")
        foo22 = get("#{@couch1}/test2_history/foo1:#{d22["rev"]}")
        foo23 = get("#{@couch1}/test2_history/foo:#{d23["rev"]}")
        expect(foo21["foo"]).to eq("bar")
        expect(foo22["foo"]).to eq("bar22")
        expect(foo23["foo"]).to eq("baz")

        foo31 = get("#{@couch2}/test3_history/foo:#{d31["rev"]}")
        foo32 = get("#{@couch2}/test3_history/foo1:#{d32["rev"]}")
        foo33 = get("#{@couch2}/test3_history/foo:#{d33["rev"]}")
        expect(foo31["foo"]).to eq("bar")
        expect(foo32["foo"]).to eq("bar23")
        expect(foo33["foo"]).to eq("baz")

        stop
    end

end

