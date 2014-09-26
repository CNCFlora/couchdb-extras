
require 'rspec'
require_relative '../lib/couch_http'


def run() 
    fork {
        system("ruby -Ilib bin/couchdb2couchdb #{@couch1} #{@couch2} #{@couch3} 2>&1")
    }
    sleep 1
end

def stop() 
    system("ps -aux | grep couchdb2couchdb | grep -v grep | awk '{print $2}' | xargs kill -9")
    sleep 1
end

describe "Multi-master replication" do

    before(:all) do
        stop
        @couch1 = "http://192.168.50.151:5984"
        @couch2 = "http://192.168.50.151:5985"
        @couch3 = "http://192.168.50.151:5986"
    end

    before(:each) do
        delete("#{@couch1}/test")
        delete("#{@couch2}/test")
        delete("#{@couch3}/test")
    end

    after(:all) do
        stop
    end

    it "Simple run and dies" do
        run
        sleep 2
        stop
    end

    it "MASTER! MASTER!" do
        put("#{@couch1}/test",{})
        put("#{@couch2}/test",{})
        put("#{@couch3}/test",{})

        d1 = post("#{@couch1}/test",{:_id=>"foo1",:foo=>"bar1"})
        d2 = post("#{@couch2}/test",{:_id=>"foo2",:foo=>"bar2"})
        d3 = post("#{@couch3}/test",{:_id=>"foo3",:foo=>"bar3"})

        run

        sleep 1

        foo = get("#{@couch1}/test/foo1")
        expect(foo["foo"]).to eq('bar1')
        foo = get("#{@couch1}/test/foo2")
        expect(foo["foo"]).to eq('bar2')
        foo = get("#{@couch1}/test/foo3")
        expect(foo["foo"]).to eq('bar3')

        foo = get("#{@couch2}/test/foo1")
        expect(foo["foo"]).to eq('bar1')
        foo = get("#{@couch2}/test/foo2")
        expect(foo["foo"]).to eq('bar2')
        foo = get("#{@couch2}/test/foo3")
        expect(foo["foo"]).to eq('bar3')

        foo = get("#{@couch3}/test/foo1")
        expect(foo["foo"]).to eq('bar1')
        foo = get("#{@couch3}/test/foo2")
        expect(foo["foo"]).to eq('bar2')
        foo = get("#{@couch3}/test/foo3")
        expect(foo["foo"]).to eq('bar3')
    end

end

