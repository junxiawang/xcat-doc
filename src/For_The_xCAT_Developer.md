Want to Help Make xCAT Better?

We're glad you want to help! Every contribution from the xCAT community makes xCAT that much better. Here's what you should know before you start contributing: 

  * [XCAT_2_Architecture](XCAT_2_Architecture)
  * [xCAT 2 Programming Tips](Programming_Tips) 
  * [XCAT_Developer_Guide](XCAT_Developer_Guide) includes [contribution agreement](XCAT_Developer_Guide/#contributor-and-maintainer-agreements)  
  * You can view the [xCAT Source Code](https://sourceforge.net/p/xcat/xcat-core/ci/master/tree)
  * To create a local git repository for development.
    * Install git 
      * yum install git (usually works) 
    * Configure git on your machine: 
      * git config --global user.name "Your Name Comes Here" 
      * git config --global user.email you@yourdomain.example.com 
    * Create a local git repo from sourceforge (only gets the master branch) 
      * git clone ssh://&lt;sf-userid&gt;@git.code.sf.net/p/xcat/xcat-core xcat-core 
      * (replace &lt;sf-userid&gt; with your sourceforge userid) 
  * Or create a local repository from a release 
    * To get the other branches, cd into local repo, then: 
      * git fetch origin 
      * git checkout -b 2.8 origin/2.8 
      * git checkout -b 2.7 origin/2.7 
  * Submit patches to the [xCAT mailing list](https://lists.sourceforge.net/lists/listinfo/xcat-user) (after signing/submitting the [contribution agreement](XCAT_Developer_Guide/#contributor-and-maintainer-agreements)) 
  * When you know enough about xCAT (and we know enough about you) that you want to commit code changes to the git repository, [get a sourceforge id](https://sourceforge.net/user/registration), and request git commit authority on the mailing list. 

For the More Experienced xCAT Developer

  * [XCAT_2_Mini_Designs_for_New_Features](XCAT_2_Mini_Designs_for_New_Features) 
  * [Wish List](Wish_List_for_xCAT_2) 
  * [Node_Deployment_and_Software_Maintenance](Node_Deployment_and_Software_Maintenance) 
  * [Hierarchical_Design](Hierarchical_Design)
  * [Setup_Your_Development_Testing_Clusters_on_One_Physical_Machine](Setup_Your_Development_Testing_Clusters_on_One_Physical_Machine) 
  * [XCAT_2_Packaging](XCAT_2_Packaging)
  * [XCAT_2_Security](XCAT_2_Security)
  * [Release_Notes](Release_Notes)
