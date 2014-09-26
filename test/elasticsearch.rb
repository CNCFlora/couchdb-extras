
require 'rspec'
require_relative '../lib/couch_http'


def run() 
    fork {
        system("ruby -Ilib bin/couchdb2elasticsearch #{@couch1} #{@es1}")
    }
    sleep 1
end

def stop() 
    system("ps -aux | grep couchdb2elasticsearch  | grep -v grep | awk '{print $2}' | xargs kill -9")
    sleep 1
end

describe "ElasticSearch" do

    before(:all) do
        stop
        @couch1 = "http://localhost:5984"
        @es1 = "http://localhost:9200"
    end

    before(:each) do
        delete("#{@couch1}/test")
        delete("#{@couch1}/test2")
        delete("#{@es1}/test")
        delete("#{@es1}/test2")
    end

    after(:all) do
        stop
    end

    it "Simple run and dies" do
        run
        sleep 2
        stop
    end

    it "Index an existing DB" do
        put("#{@couch1}/test",{})

        run

        d1 = post("#{@couch1}/test",{:_id=>"foo",:foo=>"bar"})
        d2 = post("#{@couch1}/test",{:_id=>"foo1",:foo=>"bar2"})
        d3 = post("#{@couch1}/test",{:_id=>"foo",:foo=>"baz",:_rev=>d1["rev"]})

        sleep 2

        r = get("#{@es1}/test/_search?q=*")
        expect(r["hits"]["hits"].length).to eq(2)

        r = get("#{@es1}/test/_search?q=bar2")
        expect(r["hits"]["hits"].length).to eq(1)
        expect(r["hits"]["hits"][0]["_source"]["id"]).to eq('foo1')

        r = get("#{@es1}/test/_search?q=baz")
        expect(r["hits"]["hits"].length).to eq(1)
        expect(r["hits"]["hits"][0]["_source"]["id"]).to eq('foo')

        delete("#{@couch1}/test/foo?rev=#{d3["rev"]}")

        sleep 0.5

        r = get("#{@es1}/test/_search?q=baz")
        expect(r["hits"]["hits"].length).to eq(0)

        stop
    end

    it "Sync an existing DB and new DBs" do
        put("#{@couch1}/test",{})

        run

        put("#{@couch1}/test2",{})

        sleep 1

        d0 = post("#{@couch1}/test",{:_id=>"fuz",:foo=>"bar"})
        d1 = post("#{@couch1}/test2",{:_id=>"foo",:foo=>"bar"})
        d2 = post("#{@couch1}/test2",{:_id=>"foo1",:foo=>"bar2"})
        d3 = post("#{@couch1}/test2",{:_id=>"foo",:foo=>"baz",:_rev=>d1["rev"]})

        sleep 1

        r = get("#{@es1}/test/_search?q=*")
        expect(r["hits"]["hits"].length).to eq(1)
        expect(r["hits"]["hits"][0]["_source"]["id"]).to eq('fuz')

        r = get("#{@es1}/test2/_search?q=*")
        expect(r["hits"]["hits"].length).to eq(2)

        r = get("#{@es1}/test2/_search?q=bar2")
        expect(r["hits"]["hits"].length).to eq(1)
        expect(r["hits"]["hits"][0]["_source"]["id"]).to eq('foo1')

        r = get("#{@es1}/test2/_search?q=baz")
        expect(r["hits"]["hits"].length).to eq(1)
        expect(r["hits"]["hits"][0]["_source"]["id"]).to eq('foo')

        delete("#{@couch1}/test/foo?rev=#{d3["rev"]}")

        sleep 0.5

        r = get("#{@es1}/test/_search?q=baz")
        expect(r["hits"]["hits"].length).to eq(0)

        stop
    end

end

