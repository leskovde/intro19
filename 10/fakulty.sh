#!/bin/awk -f

BEGIN {
# initialization
        FS="\t";
        prac_map[""] = 0
        osoby_map[""] = 0
        garbage[""] = 0
        prac_count = 0
        osoby_count = 0
}

function do_cfg(map)
{
        for (i = 1; i<NF+1; i++)
        {
        # $i --> i-th field
                map[$i] = i
        }
}

function do_pracoviste()
{
        id = $prac_map["id"]
        name = $prac_map["name"]
        parent = $prac_map["parent"]
        director = $prac_map["director"]

        pracoviste[id ".name"] = name
        pracoviste[id ".parent"] = parent
        pracoviste[id ".director"] = director
        # total number of sites
        prac_count++
}

function do_osoby()
{
        id = $osoby_map["id"]
        name =  $osoby_map["name"]
        phone = $osoby_map["phone"]
        email = $osoby_map["email"]
        department = $osoby_map["department"]

        osoby[id ".name"] = name
        osoby[id ".phone"] = phone
        osoby[id ".email"] = email
        # linking multiple sites
        if(department !~ /;/)
        {
                osoby[id ".department"] = department
        }
        else
        {
                garbage[id] = department
                sub(/;.*/, "")
                osoby[id ".department"] = $osoby_map["department"]
        }
        osoby_count++
}

{
        if (FILENAME == "osoby.cfg") {
                do_cfg(osoby_map)
        } else if (FILENAME == "pracoviste.cfg") {
                do_cfg(prac_map)
        } else if (FILENAME == "osoby.in") {
                do_osoby()
        } else if (FILENAME == "pracoviste.in") {
                do_pracoviste()
        }
}

END {
        # new link ID counter
        high_count = osoby_count + 1
        # main loop - sites
        for(y = 1; y<=prac_count; y++)
        {
                print "node " y " {"
                print pracoviste[y ".name"]
                print pracoviste[y ".parent"]
                print pracoviste[y ".director"]
        # secondary loop - people
                for(x = 1; x<=osoby_count; x++)
                {
                        if (osoby[x ".department"] == y)
                        {
                          print "person " x " {"
                          print osoby[x ".name"]
                          print osoby[x ".phone"]
                          print osoby[x ".email"]
                          print "}"
                        } else if (garbage[x] ~ ".*;y*.")
                        {
                          print "link {"
                          print "ref " high_count
                          print "}"
                        }
                }
                print "}"
        }

}
