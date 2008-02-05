--# -path=.:../abstract:../common:../../prelude

--1 Bulgarian auxiliary operations.

-- This module contains operations that are needed to make the
-- resource syntax work. To define everything that is needed to
-- implement $Test$, it moreover contains regular lexical
-- patterns needed for $Lex$.

resource ResBul = ParamX ** open Prelude in {

  flags optimize=all ;

-- Some parameters, such as $Number$, are inherited from $ParamX$.

--2 For $Noun$

-- This is the worst-case $Case$ needed for pronouns.

  param
    Case = Nom | Acc | Gen AForm;
    
    GenNum = GSg Gender | GPl ;

-- Agreement of $NP$ is a record. We'll add $Gender$ later.

  oper
    Agr = {gn : GenNum ; p : Person} ;

  param
    Gender = Masc | Fem | Neut ;
    
    Dt = NDet | Det ;

-- The plural never makes a gender distinction.

--2 For $Verb$

    VForm = 
       VPres      Number Person
     | VAorist    Number Person
     | VImperfect Number Person
     | VPerfect    AForm
     | VPluPerfect AForm
     | VPassive    AForm
     | VPresPart   AForm
     | VImperative Number
     | VGerund
     ;

-- The order of sentence is needed already in $VP$.

    Order = ODir | OQuest ;

--2 For $Adjective$

    AForm = 
       ASg Gender Dt
     | APl Dt
     | AFullDet
     ;

--2 Transformations between parameter types

  oper
    agrP3 : GenNum -> Agr = \gn -> 
      {gn = gn ; p = P3} ;

    gennum : Gender -> Number -> GenNum = \g,n ->
      case n of {
        Sg => GSg g ;
        Pl => GPl
        } ;

    numGenNum : GenNum -> Number = \gn -> 
      case gn of {
        GSg _  => Sg ;
        GPl    => Pl
      } ;

    aformGenNum : GenNum -> AForm = \gn -> 
      case gn of {
        GSg g  => ASg g NDet ;
        GPl    => APl NDet
      } ;

  oper
-- For $Verb$.

    Verb : Type = {
      s : VForm => Str ;
    } ;

    VP : Type = {
      s   : Tense => Anteriority => Polarity => Agr => Str ;
      imp : Polarity => Number => Str ;
      s2  : Agr => Str
    } ;

    predV : Verb -> VP =
      \verb -> 
        let pol : Polarity -> Str -> Str = \p,vf -> case p of { Pos => vf ; Neg => "��" ++ vf }
        in { s = \\t,a,p,agr => let present = verb.s ! (VPres   (numGenNum agr.gn) agr.p) ;
                                    aorist  = verb.s ! (VAorist (numGenNum agr.gn) agr.p) ;
                                    perfect = verb.s ! (VPerfect (aformGenNum agr.gn)) ;
                                    vf = case <t,a> of {
                                           <Pres,Simul> => present ;
                                           <Pres,Anter> => auxBe.s ! (VPres (numGenNum agr.gn) agr.p) ++ perfect ;
                                           <Past,Simul> => aorist ;
                                           <Past,Anter> => auxBe.s ! (VAorist (numGenNum agr.gn) agr.p) ++ perfect ;
                                           <Fut, Simul> => "��" ++ present ;
                                           <Fut, Anter> => "��" ++ auxBe.s ! (VPres (numGenNum agr.gn) agr.p) ++ perfect ;
                                           <Cond,Simul> => auxWould.s ! (VAorist (numGenNum agr.gn) agr.p) ++ perfect ;
                                           <Cond,Anter> => auxWould.s ! (VAorist (numGenNum agr.gn) agr.p) ++ auxBe.s ! (VPerfect (aformGenNum agr.gn)) ++ perfect
                                         } ;
                                in pol p vf ;
             imp = \\p,n => pol p (verb.s ! VImperative n) ;
             s2 = \\_ => []
           } ;

    insertObj : (Agr => Str) -> VP -> VP = \obj,vp -> {
      s = vp.s ;
      imp = vp.imp ;
      s2 = \\a => vp.s2 ! a ++ obj ! a
      } ;

    auxBe : Verb = {
      s = table {
            VPres      Sg P1 => "���" ; 
            VPres      Sg P2 => "��" ;
            VPres      Sg P3 => "�" ; 
            VPres      Pl P1 => "���" ; 
            VPres      Pl P2 => "���" ;
            VPres      Pl P3 => "��" ;
            VAorist    Sg P1 => "���" ; 
            VAorist    Sg _  => "����" ;
            VAorist    Pl P1 => "�����" ; 
            VAorist    Pl P2 => "�����" ;
            VAorist    Pl P3 => "����" ;
            VImperfect Sg P1 => "���" ; 
            VImperfect Sg _  => "����" ;
            VImperfect Pl P1 => "�����" ; 
            VImperfect Pl P2 => "�����" ;
            VImperfect Pl P3 => "����" ;
            VPerfect    aform => (regAdjective "���").s ! aform ;
            VPluPerfect aform => (regAdjective "���").s ! aform ;
            VPassive    aform => (regAdjective "�����").s ! aform ;
            VPresPart   aform => (regAdjective "�����").s ! aform ;
            VImperative Sg => "����" ;
            VImperative Pl => "������" ;
            VGerund        => "�������"
          }
      } ;

    auxWould : Verb = {
      s = table {
            VPres      Sg P1 => "����" ; 
            VPres      Sg P2 => "�����" ;
            VPres      Sg P3 => "����" ; 
            VPres      Pl P1 => "�����" ; 
            VPres      Pl P2 => "������" ;
            VPres      Pl P3 => "�����" ;
            VAorist    Sg P1 => "���" ; 
            VAorist    Sg _  => "��" ;
            VAorist    Pl P1 => "�����" ; 
            VAorist    Pl P2 => "�����" ;
            VAorist    Pl P3 => "����" ;
            VImperfect Sg P1 => "�����" ; 
            VImperfect Sg _  => "������" ;
            VImperfect Pl P1 => "�������" ; 
            VImperfect Pl P2 => "�������" ;
            VImperfect Pl P3 => "������" ;
            VPerfect    aform => (regAdjective "���").s ! aform ;
            VPluPerfect aform => (regAdjective "�����").s ! aform ;
            VPassive    aform => (regAdjective "�����").s ! aform ;
            VPresPart   aform => (regAdjective "�����").s ! aform ;
            VImperative Sg => "����" ;
            VImperative Pl => "������" ;
            VGerund        => "�������"
          }
      } ;

    ia2e : Str -> Str =           -- to be used when the next syllable has vowel different from "�","�","�" or "�"
      \s -> case s of {
              x@(_*+_) + "�" + y@(("�"|"�"|"�"|"�"|"�"|"�"|"�"|"�"|"�"|"�"|"�"|"�"|"�"|"�"|"�"|"�"|"�"|"�"|"�"|"�")*)
                => x+"e"+y;
              _ => s
            };

    mkAdjective : (_,_,_,_,_,_,_,_,_ : Str) -> {s : AForm => Str} = 
      \dobyr,dobria,dobriat,dobra,dobrata,dobro,dobroto,dobri,dobrite -> {
      s = table {
        ASg Masc NDet  => dobyr ;
        ASg Masc Det   => dobria ;
        AFullDet       => dobriat ;
        ASg Fem  NDet  => dobra ;
        ASg Fem  Det   => dobrata ;
        ASg Neut NDet  => dobro ;
        ASg Neut Det   => dobroto ;
        APl NDet       => dobri ;
        APl Det        => dobrite
        }
      } ;

    regAdjective : Str -> {s : AForm => Str} = 
      \base -> mkAdjective base 
                           (base+"��")
                           (base+"���")
                           (base+"a")
                           (base+"���")
                           (base+"�")
                           (base+"���")
                           (ia2e base+"�")
                           (ia2e base+"���") ;

    mkVerb : (_,_,_,_,_,_,_,_,_:Str) -> Verb = 
      \cheta,chete,chetoh,chetqh,chel,chetql,cheten,chetqst,cheti -> {
      s = table {
            VPres      Sg P1 => cheta;
            VPres      Sg P2 => chete + "�";
            VPres      Sg P3 => chete;
            VPres      Pl P1 => case chete of {
                                  _ + ("�"|"�") => chete + "��";
                                  _             => chete + "�"
                                };
            VPres      Pl P2 => chete + "��";
            VPres      Pl P3 => case cheta of {
                                  vika + "�" => case chete of {
                                                  dad + "�" => dad + "��";
                                                  vika      => vika + "�"
                                                };
                                  _          => cheta + "�"
                                };
            VAorist    Sg P1 => chetoh;
            VAorist    Sg _  => case chetoh of {
                                  chet+"��" => chete;
                                  zova+ "�" => zova
                                };
            VAorist    Pl P1 => chetoh + "��";
            VAorist    Pl P2 => chetoh + "��";
            VAorist    Pl P3 => chetoh + "�";
            VImperfect Sg P1 => chetqh;
            VImperfect Sg _  => case chete of {
	                          rabot + "�" => rabot + "e��";
	                          _           => chete + "��"
                                };
            VImperfect Pl P1 => chetqh + "��";
            VImperfect Pl P2 => chetqh + "��";
            VImperfect Pl P3 => chetqh + "�";
            VPerfect aform   =>let chel1 : Str =
                                     case chel of {
                                       pas+"��" => pas+"�";
                                       _        => chel
                                     }
                               in (mkAdjective chel
                                               (chel+"��")
                                               (chel+"���")
                                               (chel1+"a")
                                               (chel1+"���")
                                               (chel1+"�")
                                               (chel1+"���")
                                               (ia2e chel1+"�")
                                               (ia2e chel1+"���")).s ! aform ;
            VPluPerfect aform => (regAdjective chetql ).s ! aform ;
            VPassive    aform => (regAdjective cheten ).s ! aform ;
            VPresPart   aform => (regAdjective chetqst).s ! aform ;
            VImperative Sg => cheti;
            VImperative Pl => case cheti of {
	                        chet + "�" => chet + "���";
	                        ela        => ela  + "��"
                              };
            VGerund => case chete of {
                         rabot + "�" => rabot + "����";
                         _           => chete + "���"
                       }
          } ;
    } ;  
    
-- For $Sentence$.

    Clause : Type = {
      s : Tense => Anteriority => Polarity => Order => Str
      } ;

    mkClause : Str -> Agr -> VP -> Clause =
      \subj,agr,vp -> {
        s = \\t,a,b,o => 
          let 
            verb  = vp.s ! t ! a ! b ! agr ;
            compl = vp.s2 ! agr
          in case o of {
              ODir   => subj ++ verb ++ compl ;
              OQuest => subj ++ verb ++ "��" ++ compl
             }
      } ;

    mkIP : Str -> GenNum -> {s : Str ; gn : GenNum} =
      \s,gn -> {
      s = s ;
      gn = gn
      } ;

    mkNP : (az,men,moj,moia,moiat,moia_,moiata,moe,moeto,moi,moite : Str) -> GenNum -> Person -> {s : Case => Str ; a : Agr} =
      \az,men,moj,moia,moiat,moia_,moiata,moe,moeto,moi,moite,gn,p -> {
      s = table {
            Nom => az ;
            Acc => men ;
            Gen aform => (mkAdjective moj moia moiat moia_ moiata moe moeto moi moite).s ! aform
          } ;
      a = {
           gn = gn ;
           p = p
          }
      } ;

    mkQuestion : 
      {s : Str} -> Clause -> 
      {s : Tense => Anteriority => Polarity => QForm => Str} = \wh,cl ->
      {
      s = \\t,a,p => 
            let cls = cl.s ! t ! a ! p ;
                why = wh.s
            in table {
                 QDir   => why ++ cls ! OQuest ;
                 QIndir => why ++ cls ! ODir
               }
      } ;
}
